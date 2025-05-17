extends Node2D

var units = []
@export var PlayerScene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	#get_units()
	#print(units)
	$"0/Base0".team = 1
	$"1/Base1".team = 0
	var index = 0
	for i in Game.players:
		var currentPlayer = PlayerScene.instantiate()
		#currentPlayer.team = index
		#currentPlayer.id = i
		
		add_child(currentPlayer, true)
		currentPlayer.init(i, index)
		for spawn in get_tree().get_nodes_in_group("PlayerSpawnPoint"):
			if spawn.name == str(index):
				print("player index = "+ str(index))
				currentPlayer.global_position = spawn.global_position
		index += 1
	var camera : Camera2D	= $Camera
	if !multiplayer.is_server():
		camera.position.x = get_tree().get_root().get_node("World/0/Base0").position.x
		camera.position.y = get_tree().get_root().get_node("World/0/Base0").position.y

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
