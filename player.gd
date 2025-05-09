extends Node2D

var units = []
var id : int
var team : int
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	if multiplayer.get_unique_id() == id:
		$UI/SpawnMenu.connect("spawn_requested", _on_spawn_requested)

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_spawn_requested(unit_type: String):
	var spawn_pos = get_spawn_position()
	spawn_unit.rpc(spawn_pos, team, id, unit_type)

func get_spawn_position() -> Vector2:
	var base_pos = global_position  # or buildingPosition or spawn point
	var offset = Vector2(rng.randf_range(-20, 20), rng.randf_range(-100, -50))
	return base_pos + offset

@rpc("any_peer", "reliable")
func spawn_unit(spawn_pos: Vector2, team: int, owner_id: int, unit_type: String):
	var unit_scene: PackedScene
	match unit_type:
		"melee": unit_scene = preload("res://units/Unit.tscn")
		"ranged": unit_scene = preload("res://units/ranged_unit.tscn")
		"villager": unit_scene = preload("res://units/villager.tscn")
		_: return
	
	var created_unit = unit_scene.instantiate()
	created_unit.position = get_node("../0").position
	#spawn_pos + Vector2(rng.randf_range(-20, 20), rng.randf_range(-100, -50))
	created_unit.team = team
	created_unit.set_multiplayer_authority(owner_id)

	if Game.wood >= 2:
		Game.wood -= 2
		get_tree().get_root().get_node("World/Units").add_child(created_unit)
		print("spawned %s by player %d on team %d" % [unit_type, owner_id, team])
