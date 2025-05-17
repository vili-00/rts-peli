extends Control

@export var Address = "127.0.0.1"
@export var port = 8910
var peer
var expected_player_count = 2

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
	
#func connected_to_server():
	#print("Connected to server")
	#SendPlayerInformation.rpc_id(1, $VBoxContainer/Name.text, multiplayer.get_unique_id())
func connected_to_server():
	print("Connected to server")
	#var my_name = $VBoxContainer/Name.text
	var my_name =get_tree().root.get_node("host_menu/VBoxContainer/Name").text
	var my_id = multiplayer.get_unique_id()
	notify_server_of_player_info.rpc_id(1, my_name, my_id)

func connection_failed():
	print("Connection failed")
	
@rpc("any_peer", "reliable")
func notify_server_of_player_info(name: String, id: int):
	if !Game.players.has(id):
		Game.players[id] = {
			"name": name,
			"id": id,
			"score": 0,
			"wood":  10,   # default starting resources
			"stone": 0,
			"metal": 0,
			"team": 3
		}

		print("Registered new player:", name, id)

		# Host re-broadcasts updated full player list to everyone
	if multiplayer.is_server():
		broadcast_players.rpc(Game.players)
		
@rpc("authority", "call_local", "reliable")
func broadcast_players(players_dict):
	Game.players = players_dict
	print("Received updated player list:", Game.players)
	
func wait_until_all_players_ready():
	while Game.players.size() < expected_player_count:
		await get_tree().process_frame
	start_game()

func start_game():
	StartGame.rpc()
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

	# Host registers itself just like any client
	var my_name = $VBoxContainer/Name.text
	var my_id = multiplayer.get_unique_id()
	notify_server_of_player_info(my_name, my_id)
	


func _on_connect_button_pressed() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(Address, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)


func _on_start_button_pressed() -> void:
	if multiplayer.is_server():
		print("Start button pressed. Current player count: ", Game.players.size())
		wait_until_all_players_ready()


func _on_ip_address_text_changed(new_text: String) -> void:
	Address = new_text


func _on_port_text_changed(new_text: String) -> void:
	port = new_text



# 1) Client calls this to ask the server to place a building
func request_building_placement(building_path: String, pos: Vector2, team:int) -> void:
	rpc_id(1, "_rpc_request_place_building", building_path, pos, team)

# 2) Runs *only* on the server (authority).  It then broadcasts to all peers:
@rpc("any_peer", "call_local", "reliable")
func _rpc_request_place_building(building_path: String, pos: Vector2, team:int) -> void:
	rpc("broadcast_building_placement", building_path, pos, team)

# 3) Runs on *every* peer (including the server) — actually does the instantiation
@rpc("any_peer", "call_local", "reliable")
func broadcast_building_placement(building_path: String, pos: Vector2, team:int) -> void:
	var inst = load(building_path).instantiate()
	inst.position = pos
	inst.team = team

	# make sure your scene’s root node is really named “World”
	get_node("/root/World/Buildings").add_child(inst)
