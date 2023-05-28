tool
extends Control

var points_px: PoolVector2Array
var color: Color
var width: float
var scatter: bool 

func _draw() -> void:
	if not scatter:
		if points_px.size() > 1:
			draw_polyline(points_px, color, width, true)
	else:
		for pos in points_px:
			draw_circle(pos, width, color)
