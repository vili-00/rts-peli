extends Node2D

var units = []
var id : int
var team : int
var rng = RandomNumberGenerator.new()
@onready var label = $UI/Label5
@onready var label2 = $UI/Label6
@onready var label3 = $UI/Label7
@onready var label4 = $UI/Label8


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


	
func init(p_id: int, p_team: int):
	id = p_id
	team = p_team
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
		
func _on_spawn_requested(unit_type: String):
	var spawn_pos = get_spawn_position()
	spawn_unit.rpc(spawn_pos, team, id, unit_type)

func get_spawn_position() -> Vector2:
	var base_pos = global_position  # or buildingPosition or spawn point
	var offset = Vector2(rng.randf_range(-20, 20), rng.randf_range(-100, -50))
	return base_pos + offset

@rpc("any_peer", "call_local", "reliable")
func spawn_unit(spawn_pos: Vector2, team: int, owner_id: int, unit_type: String):
	var unit_scene: PackedScene
	var p = Game.players[id]
	match unit_type:
		"melee": unit_scene = preload("res://units/Unit.tscn")
		"ranged": unit_scene = preload("res://units/ranged_unit.tscn")
		"villager": unit_scene = preload("res://units/villager.tscn")
		_: return
	
	var created_unit = unit_scene.instantiate()
	created_unit.position = get_node("../0").position + Vector2(rng.randf_range(-20, 20), rng.randf_range(-100, -50))
	#spawn_pos + Vector2(rng.randf_range(-20, 20), rng.randf_range(-100, -50))
	created_unit.team = team
	created_unit.add_to_group("units", true)
	created_unit.set_multiplayer_authority(owner_id)
	if multiplayer.is_server():
		if p["wood"] > 0:
			p["wood"] -= 1
			get_tree().get_root().get_node("World/Units").add_child(created_unit)
			print("spawned %s by player %d on team %d" % [unit_type, owner_id, team])
	else:
		# Still add to scene for sync
		if p["wood"] > 0:
			p["wood"] -= 1
			get_tree().get_root().get_node("World/Units").add_child(created_unit)
			print("spawned %s by player %d on team %d" % [unit_type, owner_id, team])
