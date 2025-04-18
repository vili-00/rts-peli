extends Camera2D

@export var speed = 15
@export var zoom_speed = 20.0
@export var zoom_margin = 0.1
@export var zoom_min = 0.5
@export var zoom_max = 3.0

var mousePos = Vector2()
var mousePosGlobal = Vector2() 
var start = Vector2()
var startV = Vector2()
var end = Vector2()
var endV = Vector2()
var pos = Vector2()
var isDragging = false
signal area_selected
signal start_move_selection
@onready var selectionBox = get_node("../UI/Panel")

func _ready():
	connect("area_selected", Callable(get_parent(), "_on_area_selected"))
func _process(delta):
	var inputX = int(Input.is_action_pressed("Ui_Right")) - int(Input.is_action_pressed("Ui_Left"))
	var inputY =  int(Input.is_action_pressed("Ui_Down")) - int(Input.is_action_pressed("Ui_Up"))
	
	position.x = lerp(position.x, position.x + inputX*speed*zoom.x, speed*delta)
	position.y = lerp(position.y, position.y + inputY*speed*zoom.x, speed*delta)
	
	
	if Input.is_action_just_pressed("LeftClick"):
		start = mousePosGlobal
		startV = mousePos
		isDragging = true
	
	if isDragging:
		end = mousePosGlobal
		endV = mousePos
		draw_area()
		
	if Input.is_action_just_released("LeftClick"):
		if startV.distance_to(mousePos) > 10:
			end = mousePosGlobal
			endV = mousePos
			isDragging = false
			draw_area(false)
			emit_signal("area_selected", self)
		else:
			end = start
			isDragging = false
			draw_area(false)
	
func _input(event):
	if event is InputEventMouse:
		mousePos = event.position
		mousePosGlobal = get_global_mouse_position()

func draw_area(s=true):
	selectionBox.size = Vector2(abs(startV.x - endV.x), abs(startV.y - endV.y))
	pos.x = min(startV.x, endV.x)
	pos.y = min(startV.y, endV.y)
	selectionBox.position = pos
	selectionBox.size *= int(s)
	


	
