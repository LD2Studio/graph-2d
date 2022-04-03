tool
extends Control

var points_px: PoolVector2Array
var color: Color
var width: float

func _draw() -> void:
	if points_px.size() > 1:
		draw_polyline(points_px, color, width, true)

