tool
extends Control


## Minimun value on X-axis
var x_axis_min_value = 0.0 setget set_x_axis_min_value
## Maximum value on X-axis
var x_axis_max_value = 10.0 setget set_x_axis_max_value
## Number of graduations on the X-axis
var x_axis_grad_number = 11 setget set_x_axis_grad_number
## Label on the X-axis
var x_axis_label: String = "" setget set_x_axis_label

## Minimun value on Y-axis
var y_axis_min_value = 0.0 setget set_y_axis_min_value
## Maximum value on Y-axis
var y_axis_max_value = 1.0 setget set_y_axis_max_value
## Number of graduations on the Y-axis
var y_axis_grad_number = 7 setget set_y_axis_grad_number
## Label on the Y-axis
var y_axis_label: String = "" setget set_y_axis_label

## background color of graph
var background_color = Color.black setget set_background_color
## Grid visibility
var grid_horizontal_visible := false setget set_grid_horizontal_visible
var grid_vertical_visible := false setget set_grid_vertical_visible

var _curves: Array # [id: int, color: Color, width: int] 
var _value_pair_series: Array # [id: int, x_values: Array, y_values: Array, color: Color, radius: float]
var _background := ColorRect.new()
var _plot_area := Control.new()
var _max_points: int

var Plot2D = preload("res://addons/graph_2d/custom_nodes/plot_2d.gd")
var value_pairs = preload("res://addons/graph_2d/custom_nodes/value_pairs.gd")
var axis = preload("res://addons/graph_2d/custom_nodes/axis.gd").new()
var grid = preload("res://addons/graph_2d/custom_nodes/grid.gd").new()
var legend = preload("res://addons/graph_2d/custom_nodes/legend.gd").new()


const MARGIN_TOP = 30
const MARGIN_BOTTOM = 30
const MARGIN_LEFT = 45
const MARGIN_RIGHT = 30

# Plot margins
var _margin = {
	"top": 0,
	"bottom": 0,
	"left": 0,
	"right": 0
}

## Public Methods

func add_curve(label = "untitled", color = Color.red, width = 1.0) -> int:
	
	var id: int = 0
	var id_unique = false
	
	while not id_unique:
		var id_search = id
		for curve in _curves:
			if curve.id == id_search: # id exist !
				id += 1
				break
		if id_search == id:
			id_unique = true

		
	var curve: Dictionary
	curve["id"] = id
	curve["color"] = color
	curve["width"] = width
	curve["label"] = label
	curve["points"] = PoolVector2Array([])
	_curves.append(curve)
	
	var plt = Plot2D.new()
	plt.name = "Plot%d" % id
	plt.color = color
	plt.width = width
	_plot_area.add_child(plt)
	
	_update_legend()
	return curve.id
	
	
func clear_curve(id: int) -> void:
	for curve in _curves:
		if curve.id == id:
			curve.points = PoolVector2Array([])
			var plot_node = get_node("%s/Plot%d" % [_plot_area.name, curve.id])
			plot_node.points_px = PoolVector2Array([])
			plot_node.update()
			break


func remove_curve(id) -> int:
	if not id is int:
		return FAILED
		
	for curve in _curves:
		if curve.id == id:
			var plot_node = get_node("%s/Plot%d" % [_plot_area.name, curve.id])
			_plot_area.remove_child(plot_node)
			plot_node.queue_free()
			_curves.erase(curve)
			_update_legend()
			return OK
			
	return FAILED
	

func add_point(id: int, point: Vector2) -> int:
	for curve in _curves:
		if curve.id == id:
			var plot_node = get_node("%s/Plot%d" % [_plot_area.name, curve.id])
			var pts_px: PoolVector2Array = plot_node.points_px
			if pts_px.size() >= _max_points:
				return ERR_OUT_OF_MEMORY
				
			var pts: PoolVector2Array = curve.points
			pts.append(point)
			curve.points = pts
			var pt: Vector2
			pt.x = clamp(point.x, x_axis_min_value, x_axis_max_value)
			pt.y = clamp(point.y, y_axis_min_value, y_axis_max_value)
			
			var pt_px: Vector2
			pt_px.x = range_lerp(pt.x, x_axis_min_value, x_axis_max_value, 0, _plot_area.rect_size.x)
			pt_px.y = range_lerp(pt.y, y_axis_min_value, y_axis_max_value, _plot_area.rect_size.y, 0)
			
			pts_px.append(pt_px)
			plot_node.points_px = pts_px
			plot_node.update()
			break
	return OK

func add_points(id: int, points: PoolVector2Array):
	for point in points:
		add_point(id, point)

func get_points(id: int) -> PoolVector2Array:
	for plot in _curves:
		if plot.id == id:
			return plot.points
			
	return PoolVector2Array()

func add_value_pairs_series( x_values: Array, y_values: Array, color: Color, radius: float) -> int:
	
	var id: int = 0
	var id_unique = false
	
	while not id_unique:
		var id_search = id
		for series in _value_pair_series:
			if series.id == id_search: # id exist !
				id += 1
				break
		if id_search == id:
			id_unique = true
	
	var series: Dictionary
	series["id"] = id
	series["x_values"] = x_values
	series["y_values"] = y_values
	series["color"] = color
	series["radius"] = radius
	_value_pair_series.append(series)

	var vps = value_pairs.new()
	vps.name = "ValuePairs%d" % id
	vps.color = color
	vps.radius = radius
	_plot_area.add_child(vps)
	
	_update_value_pair_series()

	return id

func remove_value_pair_series(id: int) -> int:
	if not id is int:
		return FAILED
		
	for series in _value_pair_series:
		if series.id == id:
			var vps_node = get_node("%s/ValuePairs%d" % [_plot_area.name, series.id])
			_plot_area.remove_child(vps_node)
			vps_node.queue_free()
			_value_pair_series.erase(series)
			return OK
			
	return FAILED

func clear_value_pair_series(id: int) -> int:
	if not id is int:
		return FAILED
		
	for series in _value_pair_series:
		if series.id == id:
			var vps_node = get_node("%s/ValuePairs%d" % [_plot_area.name, series.id])
			vps_node.value_pair_positions = []
			return OK
	
	return FAILED

## Internal Methods

func _ready() -> void:
	_setup_graph()
	_update_plot()
	_update_value_pair_series()
	var polygon_buffer = ProjectSettings.get_setting("rendering/limits/buffers/canvas_polygon_buffer_size_kb")
	_max_points = polygon_buffer * 1024 /16
	
func _setup_graph():
	_background.name = "Background"
	_background.color = background_color
	_background.anchor_right = 1.0
	_background.anchor_bottom = 1.0
	add_child(_background)
	
	_plot_area.name = "PlotArea"
	_plot_area.anchor_right = 1.0
	_plot_area.anchor_bottom = 1.0
	_plot_area.margin_left = MARGIN_LEFT
	_plot_area.margin_top = MARGIN_TOP
	_plot_area.margin_right = -MARGIN_RIGHT
	_plot_area.margin_bottom = -MARGIN_BOTTOM
	add_child(_plot_area)
	
	axis.name = "Axis"
	add_child(axis)
	grid.name = "Grid"
	add_child(grid)
	legend.name = "Legend"
	add_child(legend)
	
	connect("resized", self, "_on_Graph_resized")
	_plot_area.connect("resized", self, "_on_Plot_area_resized")

	move_child(legend, 0)
	move_child(grid, 0)
	move_child(axis, 0)
	move_child(_plot_area, 0)
	move_child(_background, 0)

func _update_margins() -> void:
	_margin.left = MARGIN_LEFT if y_axis_label == "" else MARGIN_LEFT + 20
	_margin.bottom = MARGIN_BOTTOM if x_axis_label == "" else MARGIN_BOTTOM + 20

func _update_axis() -> void:

	# Vertical Graduation
	var y_axis_range: float = y_axis_max_value - y_axis_min_value
	# Horizontal Graduation
	var x_axis_range: float = x_axis_max_value - x_axis_min_value
	# Plot area height in pixel
	var area_height = rect_size.y - MARGIN_TOP - _margin.bottom
	var vert_grad_step_px = area_height / (y_axis_grad_number - 1)
	# Plot area width in pixel
	var area_width = rect_size.x - _margin.left - MARGIN_RIGHT
	var hor_grad_step_px = area_width / (x_axis_grad_number -1)
	
	var vert_grad: Array
	var hor_grid: Array
	var grad_px: Vector2
	
	grad_px.x = _margin.left
	
	for n in range(y_axis_grad_number):
		var grad: Array = []
		grad_px.y = MARGIN_TOP + n * vert_grad_step_px
		grad.append(grad_px)
		var grad_text = "%0.*f" %  [
			2 if y_axis_range/(y_axis_grad_number-1) < 0.1 else 1,
			(float(y_axis_max_value) - n * float(y_axis_range)/(y_axis_grad_number-1))
			]
		grad.append(grad_text)
		vert_grad.append(grad)
		
		# Horizontal grid
		if grid_horizontal_visible:
			var grid_px: PoolVector2Array
			grid_px.append(grad_px)
			grid_px.append(Vector2(grad_px.x + area_width, grad_px.y))
			hor_grid.append(grid_px)
			
	axis.vert_grad = vert_grad
	if grid_horizontal_visible:
		grid.hor_grid = hor_grid
	else:
		grid.hor_grid = []
		
	var hor_grad: Array
	var vert_grid: Array
	grad_px = Vector2()	
	grad_px.y = MARGIN_TOP + area_height
	
	for n in range(x_axis_grad_number):
		var grad: Array = []
		grad_px.x = _margin.left + n * hor_grad_step_px
		grad.append(grad_px)
		# https://docs.godotengine.org/en/3.5/tutorials/scripting/gdscript/gdscript_format_string.html#dynamic-padding
		var grad_text = "%0.*f" % [
			2 if x_axis_range/(x_axis_grad_number-1) < 0.1 else 1,
			(float(x_axis_min_value) + n * float(x_axis_range)/(x_axis_grad_number-1))
			]
		grad.append(grad_text)
		hor_grad.append(grad)
		
		# Vertical grid
		if grid_vertical_visible:
			var grid_px: PoolVector2Array
			grid_px.append(grad_px)
			grid_px.append(Vector2(grad_px.x, grad_px.y - area_height))
			vert_grid.append(grid_px)
		
	axis.hor_grad = hor_grad
	if grid_vertical_visible:
		grid.vert_grid = vert_grid
	else:
		grid.vert_grid = []
	
	axis.update()
	grid.update()
	
func _update_legend():
	var legend_array: Array
	var legend_pos_px: Vector2
	legend_pos_px.x = _margin.left + 10
	var plots_number = _curves.size()
	var n = 0
	for curve in _curves:
		var legend: Array
		legend.append(curve.label)
		legend.append(curve.color)
		legend_pos_px.y = MARGIN_TOP + 20 + n*20
		legend.append(legend_pos_px)
		legend_array.append(legend)
		n += 1
	legend.legend_array = legend_array
	legend.update()
	
func _update_plot() -> void:
	
	_plot_area.margin_left = _margin.left
	_plot_area.margin_top = MARGIN_TOP
	_plot_area.margin_right = -MARGIN_RIGHT
	_plot_area.margin_bottom = -_margin.bottom
	
	for curve in _curves:
		var pts_px: PoolVector2Array
		var pt_px: Vector2
		for pt in curve.points:
#			print(rect_size)
			pt.x = clamp(pt.x, x_axis_min_value, x_axis_max_value)
			pt.y = clamp(pt.y, y_axis_min_value, y_axis_max_value)
			pt_px.x = range_lerp(pt.x, x_axis_min_value, x_axis_max_value, 0, _plot_area.rect_size.x)
			pt_px.y = range_lerp(pt.y, y_axis_min_value, y_axis_max_value, _plot_area.rect_size.y, 0)
			pts_px.append(pt_px)
		var plt = get_node("%s/Plot%d" % [_plot_area.name, curve.id])
		
		plt.points_px = pts_px
		plt.update()
		
func _update_value_pair_series() -> void:
	_plot_area.margin_left = _margin.left
	_plot_area.margin_top = MARGIN_TOP
	_plot_area.margin_right = -MARGIN_RIGHT
	_plot_area.margin_bottom = -_margin.bottom
	
	for series in _value_pair_series:
		var pts_px: PoolVector2Array
		var pt_px: Vector2
		for pt_index in series.x_values.size():
			var x = series.x_values[pt_index]
			var y = series.y_values[pt_index]
#			print(rect_size)
			x = clamp(x, x_axis_min_value, x_axis_max_value)
			y = clamp(y, y_axis_min_value, y_axis_max_value)
			pt_px.x = range_lerp(x, x_axis_min_value, x_axis_max_value, 0, _plot_area.rect_size.x)
			pt_px.y = range_lerp(y, y_axis_min_value, y_axis_max_value, _plot_area.rect_size.y, 0)
			pts_px.append(pt_px)
		var vps = get_node("%s/ValuePairs%d" % [_plot_area.name, series.id])
		
		vps.value_pair_positions = pts_px
		vps.update()

func set_x_axis_min_value(value) -> void:
	x_axis_min_value = value
	_update_axis()
	
func set_x_axis_max_value(value) -> void:
	x_axis_max_value = value
	_update_axis()
	
func set_x_axis_grad_number(value) -> void:
	if value > 1:
		x_axis_grad_number = value
		_update_axis()
	
func set_x_axis_label(value) -> void:
	x_axis_label = value
	axis.x_label = x_axis_label
	_update_margins()
	_update_axis()
	_update_legend()
	_update_plot()
	
func set_y_axis_min_value(value) -> void:
	y_axis_min_value = value
	_update_axis()
	
func set_y_axis_max_value(value) -> void:
	y_axis_max_value = value
	_update_axis()
	
func set_y_axis_grad_number(value) -> void:
	if value > 1:
		y_axis_grad_number = value
		_update_axis()
	
func set_y_axis_label(value) -> void:
	y_axis_label = value
	axis.y_label = y_axis_label
	_update_margins()
	_update_axis()
	_update_legend()
	_update_plot()
	
func set_background_color(value):
	background_color = value
	if is_instance_valid(_background):
		_background.color = background_color
	
func set_grid_horizontal_visible(value):
	grid_horizontal_visible = value
	_update_axis()

func set_grid_vertical_visible(value):
	grid_vertical_visible = value
	_update_axis()
	
func _get_property_list() -> Array:
	var props = []
	props.append(
		{
			"name": "Graph2D",
			"type": TYPE_NIL,
			"usage": PROPERTY_USAGE_CATEGORY
		}
	)
	props.append(
		{
			"name": "background_color",
			"type": TYPE_COLOR
		}
	)
	props.append(
		{
			"name": "X Axis",
			"type": TYPE_NIL,
			"hint_string": "x_axis_",
			"usage": PROPERTY_USAGE_GROUP|PROPERTY_USAGE_SCRIPT_VARIABLE
		}
	)
	props.append(
		{
			"name": "x_axis_min_value",
			"type": TYPE_REAL
		}
	)
	props.append(
		{
			"name": "x_axis_max_value",
			"type": TYPE_REAL
		}
	)
	props.append(
		{
			"name": "x_axis_grad_number",
			"type": TYPE_INT
		}
	)
	props.append(
		{
			"name": "x_axis_label",
			"type": TYPE_STRING
		}
	)
	props.append(
		{
			"name": "Y Axis",
			"type": TYPE_NIL,
			"hint_string": "y_axis_",
			"usage": PROPERTY_USAGE_GROUP|PROPERTY_USAGE_SCRIPT_VARIABLE
		}
	)
	props.append(
		{
			"name": "y_axis_min_value",
			"type": TYPE_REAL
		}
	)
	props.append(
		{
			"name": "y_axis_max_value",
			"type": TYPE_REAL
		}
	)
	props.append(
		{
			"name": "y_axis_grad_number",
			"type": TYPE_INT
		}
	)
	props.append(
		{
			"name": "y_axis_label",
			"type": TYPE_STRING
		}
	)
	props.append(
		{
			"name": "Grid",
			"type": TYPE_NIL,
			"hint_string": "grid_",
			"usage": PROPERTY_USAGE_GROUP
		}
	)
	props.append(
		{
			"name": "grid_horizontal_visible",
			"type": TYPE_BOOL
		}
	)
	props.append(
		{
			"name": "grid_vertical_visible",
			"type": TYPE_BOOL
		}
	)
	return props


func _on_Graph_resized() -> void:
	_update_axis()
	_update_legend()

func _on_Plot_area_resized() -> void:
	_update_plot()
	_update_value_pair_series()
