extends Control

@export var Address = "127.0.0.1"
@export var port = 8910
var peer

func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)

func _process(delta):
	pass

func peer_connected(id):
	print("Player Connected " + str(id))

func peer_disconnected(id):
	print("Player Disconnected " + str(id))
	
func connected_to_server():
	print("Connected to server")
	SendPlayerInformation.rpc_id(1, $VBoxContainer/Name.text, multiplayer.get_unique_id())

func connection_failed():
	print("Connection failed")
	

@rpc("any_peer")
func SendPlayerInformation(name, id):
	if !Game.players.has(id):
		Game.players[id] = {
			"name": name,
			"id": id,
			"score": 0
		}
		
	if multiplayer.is_server():
		for i in Game.players:
			SendPlayerInformation.rpc(Game.players[i].name, i)

@rpc("any_peer","call_local")
func StartGame():
	print("Game starting")
	var scene = load("res://world.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()

func _on_host_button_pressed() -> void:
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 2)
	if error != OK:
		print("Cannot host : " + error)
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting for players")
	SendPlayerInformation.rpc_id(1,$VBoxContainer/Name.text, multiplayer.get_unique_id())
	


func _on_connect_button_pressed() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(Address, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)


func _on_start_button_pressed() -> void:
	StartGame.rpc()
