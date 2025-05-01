extends Control


func _on_test_singleplayer_pressed() -> void:
	get_tree().change_scene_to_file("res://world.tscn")
