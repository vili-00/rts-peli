extends Node2D

@onready var unit = preload("res://units/Unit.tscn")
@onready var ranged_unit = preload("res://units/ranged_unit.tscn")
@onready var villager = preload("res://units/villager.tscn")
var buildingPosition = Vector2(100,100)
signal spawn_requested(unit_type: String)

var rng = RandomNumberGenerator.new()

func _ready():
	pass
	
func showMenu(menuPos):
	SpawnMenu.position = menuPos
	SpawnMenu.visible = true
	print("showmenu")
	
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	emit_signal("spawn_requested", "villager")

func _on_button_3_pressed() -> void:
	emit_signal("spawn_requested", "ranged")

func _on_button_4_pressed() -> void:
	emit_signal("spawn_requested", "melee")


#@rpc("any_peer", "reliable")
#func spawnUnit(spawnPosition, team, owner_id):
	#var unitType = unit
	#print(spawnPosition)
	#var pathToUnits = get_tree().get_root().get_node("World/Units")
	#var createdUnit = unitType.instantiate()
	#var pathToWorld = get_tree().get_root().get_node("World")
	#var randomX = rng.randf_range(-20.0, 20.0)
	#var randomY = rng.randf_range(-100.0, -50.0)
	#spawnPosition = spawnPosition +Vector2(randomX, randomY)
	#createdUnit.position = spawnPosition
	#created_unit.team = team
	#created_unit.set_multiplayer_authority(owner_id)
	#
	#
	#if(Game.wood >= 2):
		#Game.wood -= 2
		#pathToUnits.add_child(createdUnit)
		#pathToWorld.get_units()
		#print("spawned")
		#
func spawnUnitRanged(spawnPosition):
	print(spawnPosition)
	var pathToUnits = get_tree().get_root().get_node("World/Units")
	var createdUnit = ranged_unit.instantiate()
	var pathToWorld = get_tree().get_root().get_node("World")
	var randomX = rng.randf_range(-20.0, 20.0)
	var randomY = rng.randf_range(-20.0, 20.0)
	spawnPosition = spawnPosition +Vector2(randomX, randomY)
	createdUnit.position = spawnPosition
	
	
	if(Game.wood >= 3):
		Game.wood -= 3
		pathToUnits.add_child(createdUnit)
		pathToWorld.get_units()
		print("spawned")
		
	
func spawnVillager(spawnPosition):
	var unitType = unit
	print(spawnPosition)
	var pathToUnits = get_tree().get_root().get_node("World/Units")
	var createdUnit = unitType.instantiate()
	createdUnit.team = 2
	var pathToWorld = get_tree().get_root().get_node("World")
	var randomX = rng.randf_range(-20.0, 20.0)
	var randomY = rng.randf_range(-100.0, -50.0)
	spawnPosition = spawnPosition +Vector2(randomX, randomY)
	createdUnit.position = spawnPosition
	
	
	if(Game.wood >= 1):
		Game.wood -= 1
		pathToUnits.add_child(createdUnit)
		pathToWorld.get_units()
		print("spawned")
