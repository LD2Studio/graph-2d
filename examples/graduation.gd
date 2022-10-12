tool
extends Control

func _ready():
	# Add plots to the graph
	# Return a plot id
	var id1 = $Graph2D.add_curve("Curve 1")
