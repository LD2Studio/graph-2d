tool
extends Control

func _ready() -> void:
	# Add plots to the graph
	# Return a plot id
	var plot1_id = $Graph2D.add_curve("y = 0.1*x")
	var plot2_id = $Graph2D.add_curve("y = 0.01*x^2", Color.green)

	for x in range(0,11,1):
		var y1 = 0.1 * x
		$Graph2D.add_point(plot1_id, Vector2(x, y1))
		var y2 = 0.01 * x * x
		$Graph2D.add_point(plot2_id, Vector2(x, y2))
