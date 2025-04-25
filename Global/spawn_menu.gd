extends Node2D

@onready var unit = preload("res://units/Unit.tscn")
var buildingPosition = Vector2(100,100)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	spawnUnit(unit, buildingPosition)
	

func _on_button_3_pressed() -> void:
	spawnUnit(unit, buildingPosition)


func _on_button_4_pressed() -> void:
	spawnUnit(unit, buildingPosition)


func spawnUnit(unitType, position):
	var pathToUnits = get_tree().get_root().get_node("World/Units")
	var createdUnit = unitType.instantiate()
	createdUnit.position = position
	
	if(Game.wood > 0):
		pathToUnits.add_child(createdUnit)
		print("spawned")
		
		
	
		
