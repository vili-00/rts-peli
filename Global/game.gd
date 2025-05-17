extends Node

var players = {}
var player = null
var wood = 0
var stone = 0
var metal = 0
var base_destroyed = 0
var count1 = 0
var count0 = 0
var time_left = -1# seconds remaining
var player2base
var player1base

func _process(delta: float) -> void:
	time_left -= delta
	if time_left > -1 and time_left < 9990:
		player2base= get_tree().get_root().get_node("World/1/Base1")
		player1base= get_tree().get_root().get_node("World/0/Base0")
		if player1base == null:
			base_destroyed = 1
		if player2base == null:
			base_destroyed = 2
		if base_destroyed == 1:
			print("winner player 2")
			time_left = -1
		if base_destroyed == 2:
			time_left = -1
			print("winner player 1")
		#check units count for winner if time runs out
		
		if time_left < 1:
			count0 = get_tree().get_nodes_in_group("units0").size()
			count1 = get_tree().get_nodes_in_group("units1").size()
			if count0 < count1:
				base_destroyed = 1
			else:
				base_destroyed = 2
