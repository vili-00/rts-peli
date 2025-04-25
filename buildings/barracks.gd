extends StaticBody2D

var mouseOvelap = false
@onready var select = get_node("SelectionBox")
var selection = false
@export var selected = false
@onready var box = get_node("Box")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_selected(value):
	box.visible = value
	selected = value
