tool
extends Control


onready var background = get_node("Background")


# Called when the node enters the scene tree for the first time.
func _ready():
	background.color = Color.black


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
