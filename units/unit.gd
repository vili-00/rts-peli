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
var health = 100
var attacking := false 
var team = 1
var dying := false

func _ready():
	animated_sprite.play("walking_3")
	add_to_group("units", true)
	bar.max_value = health

func _process(delta: float) -> void:
	bar.value = health
	# once health drops below 1, only the server should trigger the RPC:
	if health < 1 and not dying and multiplayer.is_server():
		dying = true
		destroy_unit.rpc()   # broadcast to everyone (with call_local)

@rpc("any_peer", "call_local", "reliable")
func destroy_unit():
		# 1) Grab the hidden synchronizer and disable public visibility
	var sync = get_node_or_null("MultiplayerSynchronizer")
	if sync:
		sync.public_visibility = false
	print("unit destroyed")
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
			animated_sprite.play("walking_3")
	velocity = position.direction_to(target) *speed
	if position.distance_to(target) > 40:
		move_and_slide()
	else:
		animated_sprite.stop()



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

func attack_loop() -> void:
	while target_unit:
		target_unit.health -= 10
		await get_tree().create_timer(1.0).timeout
	attacking = false
