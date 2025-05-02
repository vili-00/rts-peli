extends StaticBody2D

var mouseOvelap = false
var selection = false
var spawnMenu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawnMenu = get_node("/root/SpawnMenu")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("LeftClick"):
		if mouseOvelap:
			selection = !selection
			if selection:
				spawnMenu.showMenu(position)
				print("mouseovelap spawn units")
				spawnMenu.spawnUnit(position)
				
		if !mouseOvelap:
			selection = false




func _on_mouse_entered() -> void:
	print("overlap")
	mouseOvelap = true


func _on_mouse_exited() -> void:
	mouseOvelap = false
