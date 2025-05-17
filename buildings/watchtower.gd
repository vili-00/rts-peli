extends StaticBody2D

var mouseOvelap = false
var selection = false
var spawnMenu
var team = 2
@onready var bar = $ProgressBar
var target_unit = null
var health = 250
var attacking := false 
var target_queue = []
@onready var hitbox : Area2D = $Area2D

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



func _on_area_2d_body_entered(body) -> void:
	if (body.is_in_group("units") or body.is_in_group("buildings")) \
	and body.team != team and body != self:
# no risk of invalid refs here, 'body' is always valid
		if not target_queue.has(body):
			target_queue.append(body)
		if not attacking:
			attacking = true
			attack_loop.rpc()
			
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

