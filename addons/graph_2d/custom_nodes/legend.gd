tool
extends Control

var default_font: Font
var legend_array: Array # [label: String, color: Color, pos: Vector2]

func _ready():
	default_font = Control.new().get_font("font")

func _draw():
	for legend in legend_array:
		draw_string(default_font, legend[2], legend[0], legend[1])
		

