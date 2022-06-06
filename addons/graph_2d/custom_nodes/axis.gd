tool
extends Control

var default_font: Font

var vert_grad: Array # [[px: Vector2, text: String], ...]
var hor_grad: Array
var x_label: String
var y_label: String

var _x_label = Label.new()
var _y_label = Label.new()

func _ready():
	default_font = Control.new().get_font("font")
	add_child(_x_label)
	_y_label.rect_rotation = -90
	add_child(_y_label)

func _draw() -> void:
	var topleft: Vector2 = vert_grad.front()[0]
	var topright: Vector2 = Vector2(hor_grad.back()[0].x, vert_grad.front()[0].y)
	var bottomright: Vector2 = hor_grad.back()[0]
	
	for grad in vert_grad:
		draw_line(grad[0], grad[0] - Vector2(10, 0), Color.white)
		draw_string(default_font, grad[0] + Vector2(-35, -5), grad[1])
	# draw vertical line
	draw_line(topleft, vert_grad.back()[0], Color.white)
	_y_label.text = y_label
	_y_label.rect_position = Vector2(5, (bottomright.y + topleft.y)/2)
		
	for grad in hor_grad:
		draw_line(grad[0], grad[0] + Vector2(0, 10), Color.white)
		draw_string(default_font, grad[0] + Vector2(0, 20), grad[1])

	# draw horizontal line
	draw_line(hor_grad.front()[0], hor_grad.back()[0], Color.white)
	_x_label.text = x_label
	_x_label.rect_position = Vector2((bottomright.x + topleft.x)/2, bottomright.y + 20)
