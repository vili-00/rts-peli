# PlacementManager.gd
extends Node2D

var unit_to_place: String = ""
var ghost: Sprite2D
const barracksUrl: String = "res://assets/barracks.png"

func _ready() -> void:
	# get your SpawnMenu singleton or node
	var menu = get_node("/root/SpawnMenu")
	menu.connect("place_requested", Callable(self, "_on_place_requested"))
	
	# if you want a ghost sprite that follows the mouse
	ghost = $GhostSprite
	ghost.visible = false
	
func _process(_delta: float) -> void:
	if unit_to_place != "":
		var mpos = get_viewport().get_mouse_position()
		var world_pos = get_viewport().get_camera_2d().screen_to_world(mpos)
		ghost.global_position = world_pos
		
func _on_place_requested(unit_type: String) -> void:
	unit_to_place = unit_type
	# show & configure ghost
	ghost.texture = preload(barracksUrl)
	ghost.visible = true

func _unhandled_input(event: InputEvent) -> void:
	if unit_to_place == "":
		return   # nothing to place
	
	if Input.is_action_just_released("LeftClick"):
		
		# 1) figure out where in the world you clicked
		var cam = get_viewport().get_camera_2d()
		var world_pos = cam.screen_to_world(event.position)
		
		# 2) actually spawn your unit there
		SpawnMenu.spawnUnit(world_pos)
		
		# 3) clear placement state
		unit_to_place = ""
		ghost.visible = false
