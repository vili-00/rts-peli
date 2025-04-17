extends StaticBody2D

var totalTime = 5
var currentTime = totalTime
var units = 0 
@onready var bar = $ProgressBar
@onready var timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	currentTime = totalTime
	bar.max_value = totalTime


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	bar.value = currentTime
	if currentTime <= 0:
		treeChopped()


func _on_chop_area_body_entered(body: Node2D) -> void:
	if "Unit" in body.name:
		units += 1
		startChopping()


func _on_chop_area_body_exited(body: Node2D) -> void:
	pass # Replace with function body.


func _on_timer_timeout() -> void:
	currentTime -= 1+units

func startChopping():
	timer.start()
	bar.show()
	
func treeChopped():
	queue_free()
