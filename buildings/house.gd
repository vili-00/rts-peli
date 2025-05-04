extends StaticBody2D

@onready var bar = $ProgressBar
var mouseOvelap = false
var selection = false
var spawnMenu
var team = 0
var health = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawnMenu = get_node("/root/SpawnMenu")
	bar.max_value = health
	add_to_group("buildings", true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	bar.value = health
	if health < 1:
		queue_free()


func _on_input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("LeftClick"):
		if mouseOvelap:
			selection = !selection
			if selection:
				#spawnMenu.showMenu(position)
				print("mouseovelap spawn units")
				spawnMenu.spawnUnit(position)
				
		if !mouseOvelap:
			selection = false




func _on_mouse_entered() -> void:
	print("overlap")
	mouseOvelap = true


func _on_mouse_exited() -> void:
	mouseOvelap = false
