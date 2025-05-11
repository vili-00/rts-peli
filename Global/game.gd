extends Node

var players = {}
var wood = 0
var stone = 0
var metal = 0
var base_destroyed = 0


func _process(delta: float) -> void:
	if base_destroyed == 1:
		print("winner player 2")
	if base_destroyed == 2:
		print("winner player 1")
	
	base_destroyed=0
