extends Node2D

@export var PlayerScene : PackedScene

func _ready() -> void:
	
	var index = 0
	for i in Game.players:
		var currentPlayer = PlayerScene.instantiate()
		add_child(currentPlayer)
		for spawn in get_tree().get_nodes_in_group("PlayerSpawnPoint"):
			if spawn.name == str(index):
				print(index)
				currentPlayer.global_position = spawn.global_position
		index += 1
	var camera : Camera2D	= $Camera
	if !multiplayer.is_server():
		camera.position.x = 3000
		camera.position.y = 2900
