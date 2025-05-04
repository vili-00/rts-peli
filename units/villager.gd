
extends CharacterBody2D

@export var selected = false
@onready var animated_sprite = $AnimatedSprite2D
@onready var box = get_node("Box")
@onready var target = position
@onready var bar = $ProgressBar
var follow_cursor = false
var speed = 70
var currentHealth

var target_unit = null
var health = 70
var attacking := false 
var team = 1

func _ready():
	animated_sprite.play("new_animation_1")
	add_to_group("units", true)
	bar.max_value = health

func _process(delta: float) -> void:
	bar.value = health
	if health < 1:
		queue_free()
		
func set_selected(value):
	box.visible = value
	selected = value

func _input(event):
	if event.is_action_pressed("RightClick"):
		follow_cursor = true
	if event.is_action_released("RightClick"):
		follow_cursor = false


func _physics_process(delta):
	if follow_cursor == true:
		if selected:
			target = get_global_mouse_position()
			animated_sprite.play("new_animation_1")
	velocity = position.direction_to(target) *speed
	if position.distance_to(target) > 10:
		move_and_slide()
	else:
		animated_sprite.stop()


func _on_area_2d_body_entered(body) -> void:
	if body.is_in_group("units")  or body.is_in_group("buildings") and body != self:
		if body.team != team:
			target_unit = body 
			if not attacking:
				attacking = true
				attack_loop()
		
func _on_area_2d_body_exited(body) -> void:
	if body == target_unit:
		target_unit = null  

func attack_loop() -> void:
	while target_unit:
		target_unit.health -= 3
		print("attacking")
		await get_tree().create_timer(1.0).timeout
	attacking = false
