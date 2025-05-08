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
		var mouse_world = get_global_mouse_position()
		ghost.global_position = ghost.get_global_mouse_position()

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
	var world = get_tree().root.get_node("Player")
	world.add_child(ghost)

# Catch the next click anywhere
func _input(event: InputEvent) -> void:
	if not placing:
		return

	if Input.is_action_just_pressed("LeftClick"):
		var world_pos = ghost.global_position
		_finalize_placement(world_pos)
		placing = false
		placing_unit_type = null


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
