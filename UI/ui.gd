extends CanvasLayer

@onready var label = $Label
@onready var label2 = $Label2
@onready var label3 = $Label3
@onready var label4 = $Label4

func _process(delta):
	label.text = "Wood " + str(Game.wood)
	label2.text = "Stone " + str(Game.stone)
	label3.text = "Metal " + str(Game.metal)
	#label4.text = "Units " + str(Game.wood)

	
