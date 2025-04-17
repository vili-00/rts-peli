extends CharacterBody2D

@export var selected = false
@onready var animated_sprite = $AnimatedSprite2D
@onready var box = get_node("Box")
@onready var target = position
var follow_cursor = false
var speed = 50

func _ready():
	animated_sprite.play("walking_3")

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
			animated_sprite.play("walking_3")
	velocity = position.direction_to(target) *speed
	if position.distance_to(target) > 10:
		move_and_slide()
	else:
		animated_sprite.stop()
