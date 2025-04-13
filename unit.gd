extends CharacterBody2D

@export var selected = false
@onready var animated_sprite = $AnimatedSprite2D
@onready var box = get_node("Box")

func _ready():
	animated_sprite.play("walking_3")

func set_selected(value):
	print("toimii")
	box.visible = value

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	pass # Replace with function body.
