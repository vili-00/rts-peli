extends StaticBody2D

var mouseOvelap = false
var selection = false
var spawnMenu
var team = 2
@onready var bar = $ProgressBar
var target_unit = null
var health = 250
var attacking := false 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawnMenu = get_node("/root/SpawnMenu")
	add_to_group("buildings", true)
	bar.max_value = health

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	bar.value = health
	if health < 1:
		queue_free()
		


func _on_mouse_entered() -> void:
	print("overlap")
	mouseOvelap = true


func _on_mouse_exited() -> void:
	mouseOvelap = false


func attack_loop() -> void:
	while target_unit:
		target_unit.health -= 10
		#print("attacking")
		await get_tree().create_timer(1.0).timeout
	attacking = false


func _on_area_2d_body_entered(body) -> void:
	if body.is_in_group("units") or body.is_in_group("buildings") and body != self:
		if body.team != team:
			target_unit = body 
			if not attacking:
				attacking = true
				attack_loop()
		
func _on_area_2d_body_exited(body) -> void:
	if body == target_unit:
		target_unit = null  
