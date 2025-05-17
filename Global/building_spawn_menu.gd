extends Node2D

@onready var watchtower_scene = preload("res://buildings/watchtower.tscn")
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
	var world = get_tree().root.get_node("World")
	world.add_child(ghost)

# Catch the next click anywhere
func _input(event: InputEvent) -> void:
	if not placing:
		return

	if Input.is_action_just_pressed("LeftClick"):
		if ghost != null:
			var world_pos = ghost.global_position
			_finalize_placement(world_pos)
		if ghost == null:
			print("ghost null")
		placing = false
		placing_unit_type = null



func _on_button_5_pressed() -> void:
	_start_placing(watchtower_scene)
	placing_unit_type = watchtower_scene
	placing = true
	placing = true


func _on_button_7_pressed() -> void:
	_start_placing(barracks_scene)
	placing_unit_type = barracks_scene
	placing = true
	# Notify multiplayer system about building selection

func _finalize_placement(at_pos: Vector2) -> void:
	# 1) sanity check
	if not placing_unit_type:
		push_warning("No building selected!")
		return

	# 2) grab the path
	var building_path = placing_unit_type.resource_path
	print("buidling path ")
	print(building_path)
	# 3) ask the network controller to do the rest
	#    (uses rpc_id() under the hood)
	var my_id   = multiplayer.get_unique_id()
	var my_team = Game.players[my_id].team
	MultiplayerController.request_building_placement(building_path, at_pos, my_team)

	# 4) clean up your ghost & local state
	if ghost:
		ghost.queue_free()
		ghost = null
	placing_unit_type = null
