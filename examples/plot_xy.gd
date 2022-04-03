tool
extends Control

onready var graph = get_node("Graph2D")

var plot1: int

func _ready() -> void:
	pass
	plot1 = graph.add_plot()

	for x in range(0,11,1):
		var y = 0.1 * x
#		print("x=%f, y=%f" %[x,y])
		graph.add_point(plot1, Vector2(x,y))
