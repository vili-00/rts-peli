extends Node2D

@onready var soldier_scene = preload("res://units/Unit.tscn")
@onready var barracks_scene = preload("res://buildings/Barracks.tscn")
var rng = RandomNumberGenerator.new()

# State for placement
var placing_unit_type: PackedScene = null
var placing: bool = false
var ghost: Node2D = null   # will hold our preview instance

func _ready() -> void:
	rng.randomize()

func _process(delta: float) -> void:
	if placing and ghost:
		ghost.position = get_global_mouse_position()
# Call this from your building script, passing screen coords (Vector2)
func show_menu(menu_pos: Vector2) -> void:
	position = menu_pos
	visible = true
	placing = false
	placing_unit_type = null
	if ghost:
		ghost.queue_free()
		ghost = null

func _start_placing(sc: PackedScene) -> void: 
	placing_unit_type = sc
	placing = true

	# instantiate the ghost and make it semi-transparent
	ghost = sc.instantiate()
	ghost.modulate = Color(1,1,1,0.5)
	var world = get_tree().root.get_node("World")
	world.add_child(ghost)
	#add_child(ghost)
# Button signal: pick “soldier” to place

# Catch the next click anywhere
func _input(event: InputEvent) -> void:
	if not placing:
		return

	if Input.is_action_just_pressed("LeftClick"):
	
		# 1) compute world position from screen click
		var cam = get_viewport().get_camera_2d()
		var world_pos = get_global_mouse_position()

		# 2) actually spawn the unit
		#_spawn_unit(placing_unit_type, world_pos)
		_finalize_placement(world_pos)
		# 3) reset state
		placing = false
		placing_unit_type = null

# Your existing spawn logic, slightly refactored
func _spawn_unit(scene: PackedScene, at_pos: Vector2) -> void:
	var unit = scene.instantiate()
	# add a small random offset
	var rx = rng.randf_range(-20.0, 20.0)
	var ry = rng.randf_range(-100.0, -50.0)
	unit.position = at_pos + Vector2(rx, ry)

	#if Game.wood > 0:
	var units_parent = get_tree().root.get_node("World/Units")
	units_parent.add_child(unit)
	get_tree().root.get_node("World").get_units()
	print("Spawned at ", unit.position)


func _on_button_5_pressed() -> void:
	#visible = false      # hide menu
	placing_unit_type = soldier_scene
	placing = true


func _on_button_7_pressed() -> void:
	_start_placing(barracks_scene)
	placing_unit_type = barracks_scene
	placing = true

func _finalize_placement(at_pos: Vector2) -> void:
	# 1) remove the ghost
	if ghost:
		ghost.queue_free()
		ghost = null

	# 2) instantiate the real unit/building
	var inst = placing_unit_type.instantiate()
	inst.position = at_pos  # you can still add your random offset here

	# 3) parent under the right container
	var parent_path = "Buildings" if placing_unit_type == barracks_scene else "Units"
	
	var container = get_tree().current_scene.get_node(parent_path)
	container.add_child(inst)

	# 4) reset placement state
	placing = false
	placing_unit_type = null
