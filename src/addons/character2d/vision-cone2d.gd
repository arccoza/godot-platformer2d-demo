tool
extends Node2D

export(float) var radius = 100 setget set_radius, get_angle
export(float, 0, 360) var angle = 30 setget set_angle, get_angle
export(Color, RGBA) var color = ColorN("green", 0.35) setget set_color
export(int, 36, 360) var resolution = 72
export(bool) var cone_is_visible = false
var cone_points = PoolVector2Array()
var area = Area2D.new()
var owner_id = null
var shape = ConvexPolygonShape2D.new()


func set_radius(val):
	radius = val
	_update_cone_points()

func get_radius(val):
	return radius


func set_angle(val):
	angle = val
	_update_cone_points()

func get_angle(val):
	return angle


func set_color(val):
	color = val
	update()


signal found(obj, is_area)  #detected
signal lost(obj, is_area)  #ignored


func _ready():
	shape.points = cone_points
	owner_id = area.create_shape_owner(self)
	area.shape_owner_add_shape(owner_id, shape)
	area.connect("area_entered", self, "_on_entered", [true])
	area.connect("body_entered", self, "_on_entered", [false])
	area.connect("area_exited", self, "_on_exited", [true])
	area.connect("body_exited", self, "_on_exited", [false])
	add_child(area)

func _on_entered(obj, is_area):
	emit_signal("found", obj, is_area)

func _on_exited(obj, is_area):
	emit_signal("lost", obj, is_area)

func _update_cone_points():
	var ang = deg2rad(angle)
	var res = ceil((resolution/360.0) * angle * radius/360)  # Number of points in the arc.
	print(res)
	var inc = ang/res  # The size of the arc angle steps.
	ang = ang / 2  # The starting angle.
	var rad = Vector2(radius, 0)  # Radius vector.
	var ps = PoolVector2Array()
	
	# Append the center point.
	ps.append(Vector2(0, 0))
	
	# Append each of the arc points.
	for i in range(res + 1):
		var p = rad.rotated(-ang + i * inc)
		ps.append(p)
	
	cone_points = ps
	update()  # Call update to force a redraw.
	
	return cone_points

func _draw():
	_draw_cone()

func _draw_cone():
	if not (Engine.editor_hint or cone_is_visible):
		return
	
	var colors = PoolColorArray()
	var points = cone_points
	
	colors.append(color if color else ColorN("green", 0.35))
	
	for p in points:
		draw_circle(p, 2.0, colors[0])
	
	draw_polygon(points, colors)
