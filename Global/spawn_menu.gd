extends Node2D

@onready var unit = preload("res://units/Unit.tscn")
var buildingPosition = Vector2(100,100)

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
	spawnUnit(buildingPosition)
	
	

func _on_button_3_pressed() -> void:
	spawnUnit(buildingPosition)


func _on_button_4_pressed() -> void:
	spawnUnit(buildingPosition)


func spawnUnit(spawnPosition):
	var unitType = unit
	print(spawnPosition)
	var pathToUnits = get_tree().get_root().get_node("World/Units")
	var createdUnit = unitType.instantiate()
	var pathToWorld = get_tree().get_root().get_node("World")
	var randomX = rng.randf_range(-20.0, 20.0)
	var randomY = rng.randf_range(-100.0, -50.0)
	spawnPosition = spawnPosition +Vector2(randomX, randomY)
	createdUnit.position = spawnPosition
	
	
	if(Game.wood > 0):
		pathToUnits.add_child(createdUnit)
		pathToWorld.get_units()
		print("spawned")
		
func spawnUnitRanged(unitType, spawnPosition):
	print(unitType)
	print(spawnPosition)
	var pathToUnits = get_tree().get_root().get_node("World/Units")
	var createdUnit = unitType.instantiate()
	var pathToWorld = get_tree().get_root().get_node("World")
	var randomX = rng.randf_range(-20.0, 20.0)
	var randomY = rng.randf_range(-20.0, 20.0)
	spawnPosition = spawnPosition +Vector2(randomX, randomY)
	createdUnit.position = spawnPosition
	
	
	if(Game.wood > 0):
		pathToUnits.add_child(createdUnit)
		pathToWorld.get_units()
		print("spawned")
		
	
