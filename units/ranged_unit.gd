class_name RangedUnit
extends CharacterBody2D

@export var selected = false
@onready var animated_sprite = $AnimatedSprite2D
@onready var box = get_node("Box")
@onready var target = position
@onready var bar = $ProgressBar
@onready var hitbox : Area2D = $Area2D
var follow_cursor = false
var speed = 70
var currentHealth

var target_queue = []
var health = 100
var attacking := false 
var team = 1
var dying := false

func _ready():
	animated_sprite.play("new_animation_1")
	add_to_group("units", true)
	bar.max_value = health

func _process(delta: float) -> void:
	rpc("update_health", health)
	bar.value = health
	# once health drops below 1, only the server should trigger the RPC:
	if health < 1 and not dying:
		dying = true
		destroy_unit.rpc()   # broadcast to everyone (with call_local)

@rpc("any_peer", "call_local", "reliable")
func update_health(new_health: int):
	health = new_health

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
			animated_sprite.play("new_animation_1")
	velocity = position.direction_to(target) *speed
	if position.distance_to(target) > 40:
		move_and_slide()
	else:
		animated_sprite.stop()



func _on_area_2d_body_entered(body) -> void:
	if (body.is_in_group("units") or body.is_in_group("buildings")) \
	and body.team != team and body != self:
# no risk of invalid refs here, 'body' is always valid
		if not target_queue.has(body):
			target_queue.append(body)
		if not attacking:
			attacking = true
			attack_loop()

func _on_area_2d_body_exited(body) -> void:
# still valid, safe to call has()
	if target_queue.has(body):
		target_queue.erase(body)

# make this async so you can 'await' without blocking
@rpc("any_peer", "call_local", "reliable")
func attack_loop() -> void:
	while target_queue.size() > 0:
		# Pop the next candidate
		var target = target_queue.pop_front()

		# Skip if it’s no longer valid or already dead
		if not is_instance_valid(target) or target.health <= 0:
			continue

		# While it’s still alive AND still inside our area…
		while is_instance_valid(target) \
		and target.health > 0 \
		and hitbox.overlaps_body(target):
			target.health -= 10
			print("attacking ", target.name)
			await get_tree().create_timer(1.0).timeout

			# as soon as they die or exit, this inner loop ends
			# then the outer loop pops the next queued target
			# no more targets
			attacking = false
