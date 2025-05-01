extends Control


func _on_test_singleplayer_pressed() -> void:
	get_tree().change_scene_to_file("res://world.tscn")

func _on_host_pressed() -> void:
	get_tree().change_scene_to_file("res://host_menu.tscn")

func _on_join_pressed() -> void:
	get_tree().change_scene_to_file("res://join_menu.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
