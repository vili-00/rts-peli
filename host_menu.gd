extends Control

var port = null
var peer = ENetMultiplayerPeer.new()
func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")



func _on_port_text_changed(new_text: String) -> void:
	port = new_text.to_int()
	print(port)


func _on_host_button_pressed() -> void:
	peer.create_server(port)
	
