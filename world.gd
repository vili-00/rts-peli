extends Node2D

var units = []
@export var PlayerScene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	get_units()
	print(units)
	var index = 0
	for i in Game.players:
		var currentPlayer = PlayerScene.instantiate()
		#currentPlayer.team = index
		#currentPlayer.id = i
		
		add_child(currentPlayer)
		currentPlayer.init(i, index)
		for spawn in get_tree().get_nodes_in_group("PlayerSpawnPoint"):
			if spawn.name == str(index):
				print("player index = "+ str(index))
				currentPlayer.global_position = spawn.global_position
		index += 1
	var camera : Camera2D	= $Camera
	if !multiplayer.is_server():
		camera.position.x = 500
		camera.position.y = 500

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_selected(object):
	get_units()
	var start = object.start
	var end = object.end
	var area = []
	area.append(Vector2(min(start.x, end.x), min(start.y, end.y)))
	area.append(Vector2(max(start.x, end.x), max(start.y, end.y)))
	var ut = get_units_in_area(area)

	for u in units:
		u.set_selected(false)
	for u in ut:
		print("selected units = "+ str(u))
		u.set_selected(!u.selected)

func get_units_in_area(area):
	var u = []
	print("get units in area")
	for unit in units:
		if unit.position.x > area[0].x and unit.position.x < area[1].x:
			if unit.position.y > area[0].y and unit.position.y < area[1].y:
				u.append(unit)
				print("success")
	return u

func get_units():
	units = null
	units = get_tree().get_nodes_in_group("units")
	
