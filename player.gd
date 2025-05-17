extends Node2D
var units = []
var id : int
var team : int
var rng = RandomNumberGenerator.new()
@onready var label = $UI/Label5
@onready var label2 = $UI/Label6
@onready var label3 = $UI/Label7
@onready var label4 = $UI/Label8
@onready var label5 = $UI/Label9
@onready var label6 = $UI/Label10

var time_left = 10000# seconds remaining
var countdown_timer : Timer
# Called when the node enters the scene tree for the first time.
func _ready():
	get_units()


	
func init(p_id: int, p_team: int):
	id = p_id
	team = p_team
	Game.players[id]["team"] = team
	await get_tree().process_frame  # ✅ ensures node is fully in tree
	var mp = get_tree().get_multiplayer()
	if multiplayer.get_unique_id() == id:
		$UI/SpawnMenu.show()
		$UI/building_SpawnMenu.show()
		$UI/SpawnMenu.connect("spawn_requested", _on_spawn_requested)
		#$Camera2D.current = true
		print("Local player ready:", id)
		label.show()
		label2.show()
		label3.show()
		label4.show()
	else:
		label.hide()
		label2.hide()
		label3.hide()
		label4.hide()
		$UI/SpawnMenu.hide()
		$UI/building_SpawnMenu.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Game.players.has(id):
		var p = Game.players[id]
		label .text = "Wood:  %d" % p["wood"]
		label2.text = "Stone: %d" % p["stone"]
		label3.text = "Metal: %d" % p["metal"]
			# count each group
	var count0 = get_tree().get_nodes_in_group("units0").size()
	var count1 = get_tree().get_nodes_in_group("units1").size()
	# show both in Label5
	label5.text = "Player 1 score: %d   Player 2 score: %d" % [count0, count1]
	time_left -= delta
	label6.text = "Time left: %d " % time_left

		
func _on_spawn_requested(unit_type: String):
	var spawn_pos = 0
	if multiplayer.is_server():
		spawn_pos = get_tree().get_root().get_node("World/1/Base1").position + Vector2(rng.randf_range(-20, 20), rng.randf_range(-100, -50))
	else:
		spawn_pos = get_tree().get_root().get_node("World/0/Base0").position + Vector2(rng.randf_range(-20, 20), rng.randf_range(-100, -50))
	spawn_unit.rpc(spawn_pos, team, id, unit_type)

@rpc("any_peer", "call_local", "reliable")
func spawn_unit(spawn_pos: Vector2, team: int, owner_id: int, unit_type: String):
	var unit_scene: PackedScene
	var p = Game.players[id]
	match unit_type:
		"melee": unit_scene = preload("res://units/Unit.tscn")
		"ranged": unit_scene = preload("res://units/ranged_unit.tscn")
		"villager": unit_scene = preload("res://units/villager.tscn")
		_: return
	
	
	#spawn_pos =+ Vector2(rng.randf_range(-20, 20), rng.randf_range(-100, -50))
	var created_unit = unit_scene.instantiate()
	created_unit.team = team
	created_unit.set_multiplayer_authority(owner_id)
	created_unit.position = spawn_pos
	if owner_id == 1:
		if p["wood"] > 0:
			p["wood"] -= 1
			created_unit.add_to_group("units1", true)
			get_tree().get_root().get_node("World/1/Units/").add_child(created_unit)
	else: 
		if p["wood"] > 0:
			p["wood"] -= 1
			created_unit.add_to_group("units0", true)
			get_tree().get_root().get_node("World/0/Units/").add_child(created_unit)
		
		

func _on_area_selected(object):
	get_units()
	print("Uniitit" + str(units))
	var start = object.start
	var end = object.end
	var area = []
	area.append(Vector2(min(start.x, end.x), min(start.y, end.y)))
	area.append(Vector2(max(start.x, end.x), max(start.y, end.y)))
	var ut = get_units_in_area(area)
	print(ut)

	for u in units:
		u.set_selected(false)
	for u in ut:
		print("selected units = "+ str(u))
		u.set_selected(!u.selected)

func get_units_in_area(area):
	var u = []
	print("get units in area")
	print("Area: " + str(area[0].x)+ " " + str(area[0].y))
	for unit in units:
		print("Uniitin Postitio " + str(unit.position.x)+ " " + str(unit.position.y))
		if unit.position.x > area[0].x and unit.position.x < area[1].x:
			if unit.position.y > area[0].y and unit.position.y < area[1].y:
				u.append(unit)
				print("success")
	return u

func get_units():
	units = null
	if multiplayer.is_server():
		units = get_tree().get_nodes_in_group("units1")
	else:
		units = get_tree().get_nodes_in_group("units0")


	
	
