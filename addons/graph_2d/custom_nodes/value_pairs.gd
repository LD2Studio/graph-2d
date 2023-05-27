tool
extends Control

var value_pair_positions: PoolVector2Array
var color: Color
var radius: float


func _draw() -> void:
	for pos in value_pair_positions:
		draw_circle(pos, radius, color)

