tool
extends Control


var plot_id : int
var x = 0.0
var draw_enabled = false


func _ready():
	plot_id = $Graph2D.add_curve("Sin(x)", Color.red)


func _process(_delta):
	if draw_enabled:
		var y = sin(x)
		$Graph2D.add_point(plot_id, Vector2(x,y))
		x += 0.1
	
	if x > $Graph2D.x_axis_max_value:
		draw_enabled = false
		

func _on_StartButton_pressed():
	draw_enabled = true
	$Graph2D.clear_curve(plot_id)
	x = 0.0

func _on_EraseButton_pressed():
	draw_enabled = false
	$Graph2D.clear_curve(plot_id)
	x = 0.0
