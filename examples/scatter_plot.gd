tool
extends Control

func _ready() -> void:
	# Add scatter plots to the graph
	# Return a plot id
	var x_values_1: Array = [1, 2.5, 3, 4, 5.5, 7, 7.5]
	var y_values_1: Array = [0.2, 0.35, 0.4, 0.6, 0.75, 0.9, 1]
	
	var x_values_2: Array = [1, 3, 5, 7, 9]
	var y_values_2: Array = [0.1, 0.33, 0.47, 0.6, 0.72]


	var plot1_id = $Graph2D.add_curve("scatter plot 1", Color.orange, 4, true)
	var plot2_id = $Graph2D.add_curve("scatter plot 2", Color.violet, 2, true)

	for index in x_values_1.size():
		var x = x_values_1[index]
		var y = y_values_1[index]
		$Graph2D.add_point(plot1_id, Vector2(x, y))
		
	for index in x_values_2.size():
		var x = x_values_2[index]
		var y = y_values_2[index]
		$Graph2D.add_point(plot2_id, Vector2(x, y))
