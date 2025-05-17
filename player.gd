extends Node2D

const SPAWN_INTERVAL := 5.0

var units = []
var id : int
var team : int
var rng = RandomNumberGenerator.new()

# per-barracks cooldown timers and queues
var barracks_timers := {}
var barracks_queues := {}

@onready var label  = $UI/Label5
@onready var label2 = $UI/Label6
@onready var label3 = $UI/Label7
@onready var label4 = $UI/Label8
@onready var label5 = $UI/Label9
@onready var label6 = $UI/Label10
@onready var label7 = $UI/Label11

var time_left
var countdown_timer : Timer

func _ready():
	rng.randomize()
	get_units()

func init(p_id: int, p_team: int):
	id = p_id
	team = p_team
	Game.players[id]["team"] = team
	await get_tree().process_frame
	var mp = get_tree().get_multiplayer()
	if multiplayer.get_unique_id() == id:
		$UI/SpawnMenu.show()
		$UI/building_SpawnMenu.show()
		$UI/SpawnMenu.connect("spawn_requested", _on_spawn_requested)
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

func _process(delta):
	# update resource & game info labels
	if Game.players.has(id):
		var p = Game.players[id]
		label.text  = "Wood:  %d" % p["wood"]
		label2.text = "Stone: %d" % p["stone"]
		label3.text = "Metal: %d" % p["metal"]

	# score
	var count0 = get_tree().get_nodes_in_group("units0").size()
	var count1 = get_tree().get_nodes_in_group("units1").size()
	label5.text = "Player 1 score: %d   Player 2 score: %d" % [count0, count1]

	# timer & winner
	time_left = Game.time_left
	label6.text = "Time left: %d" % time_left
	if Game.base_destroyed != 0:
		label7.show()
		label7.text = "Winner is Player: %d" % Game.base_destroyed

	# per-barracks spawn logic
	for bld in get_team_buildings(team):
		# init timer & queue if missing
		if not barracks_timers.has(bld):
			barracks_timers[bld] = SPAWN_INTERVAL
			barracks_queues[bld] = []

		# countdown
		barracks_timers[bld] -= delta

		# if ready and has queued units, spawn one
		if barracks_timers[bld] <= 0 and barracks_queues[bld].size() > 0:
			var unit_type = barracks_queues[bld].pop_front()
			# compute spawn position around this barracks
			var spawn_pos = bld.position + Vector2(
				rng.randf_range(-20,20),
				rng.randf_range(-100,-50)
			)
			# send RPC to spawn
			spawn_unit.rpc(spawn_pos, team, id, unit_type)
			# reset cooldown
			barracks_timers[bld] = SPAWN_INTERVAL

func _on_spawn_requested(unit_type: String):
	# pick a barracks at random
	var team_buildings = get_team_buildings(team)
	if team_buildings.is_empty():
		push_warning("No barracks available!")
		return
	var bld = team_buildings[rng.randi_range(0, team_buildings.size() - 1)]
	# enqueue for that barracks
	if not barracks_queues.has(bld):
		barracks_queues[bld] = []
	barracks_queues[bld].append(unit_type)

@rpc("any_peer", "call_local", "reliable")
func spawn_unit(spawn_pos: Vector2, team: int, owner_id: int, unit_type: String):
	var unit_scene: PackedScene
	var p = Game.players[id]
	match unit_type:
		"melee":   unit_scene = preload("res://units/Unit.tscn")
		"ranged":  unit_scene = preload("res://units/ranged_unit.tscn")
		"villager":unit_scene = preload("res://units/villager.tscn")
		_: return

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
	var start = object.start
	var end = object.end
	var area = [Vector2(min(start.x, end.x), min(start.y, end.y)),
				 Vector2(max(start.x, end.x), max(start.y, end.y))]
	var ut = get_units_in_area(area)
	for u in units:
		u.set_selected(false)
	for u in ut:
		u.set_selected(!u.selected)

func get_units_in_area(area):
	var u = []
	for unit in units:
		if unit.position.x > area[0].x and unit.position.x < area[1].x \
		and unit.position.y > area[0].y and unit.position.y < area[1].y:
			u.append(unit)
	return u

func get_units():
	if multiplayer.is_server():
		units = get_tree().get_nodes_in_group("units1")
	else:
		units = get_tree().get_nodes_in_group("units0")

func get_team_buildings(team_id: int) -> Array:
	var out := []
	for b in get_tree().get_nodes_in_group("buildings"):
		if b.team == team:
			out.append(b)
	return out
