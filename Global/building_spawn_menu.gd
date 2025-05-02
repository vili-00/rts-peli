extends Node2D

@onready var soldier_scene = preload("res://units/Unit.tscn")
@onready var barracks_scene = preload("res://buildings/Barracks.tscn")
var rng = RandomNumberGenerator.new()

# State for placement
var placing_unit_type: PackedScene = null
var placing: bool = false

func _ready() -> void:
	rng.randomize()


# Call this from your building script, passing screen coords (Vector2)
func show_menu(menu_pos: Vector2) -> void:
	position = menu_pos
	visible = true
	placing = false
	placing_unit_type = null

# Button signal: pick “soldier” to place

# You can add more buttons: Worker, Ranged, etc., same pattern
# func _on_Button_Worker_pressed() -> void:
#     placing_unit_type = worker_scene; placing = true; visible = false

# Catch the next click anywhere
func _unhandled_input(event: InputEvent) -> void:
	if not placing:
		return

	if Input.is_action_just_pressed("LeftClick"):
	
		# 1) compute world position from screen click
		var cam = get_viewport().get_camera_2d()
		var world_pos = get_global_mouse_position()

		# 2) actually spawn the unit
		_spawn_unit(placing_unit_type, world_pos)

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
	placing_unit_type = barracks_scene
	placing = true
