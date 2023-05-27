tool
extends Control

func _ready() -> void:
	# Add value pairs to the graph
	# Return a value pair series id
	var x_values_1: Array = [1, 2.5, 3, 4, 5.5, 7, 7.5]
	var y_values_1: Array = [0.2, 0.35, 0.4, 0.6, 0.75, 0.9, 1]
	
	var x_values_2: Array = [1, 3, 5, 7, 9]
	var y_values_2: Array = [0.1, 0.33, 0.47, 0.6, 0.72]
	
	var value_pair_series1_id = $Graph2D.add_value_pairs_series(x_values_1, y_values_1, Color.aqua, 3)
	var value_pair_series2_id = $Graph2D.add_value_pairs_series(x_values_2, y_values_2, Color.crimson, 3)

