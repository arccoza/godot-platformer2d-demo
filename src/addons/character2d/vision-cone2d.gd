tool
extends Node2D

export(float) var radius = 100
export(float, 0, 120) var angle = 30
#export(Color, RGBA) var color = ColorN("green", 0.35)
export(bool) var cone_is_visible = false
var cone_points = PoolVector2Array() setget ,get_cone_points
var area = Area2D.new()
var owner_id = null
var shape = ConvexPolygonShape2D.new()


func get_cone_points():
	var a = deg2rad(angle/2)
	var v = Vector2(radius, 0)
	var ps = [Vector2(0, 0), v.rotated(-a), v.rotated(a)]
	
	if cone_points.size() == 3:
		cone_points[0] = ps[0]
		cone_points[1] = ps[1]
		cone_points[2] = ps[2]
	else:
		cone_points.append_array(ps)
	
	return cone_points


signal found(obj, is_area)  #detected
signal lost(obj, is_area)  #ignored


func _ready():
	shape.points = self.cone_points
	owner_id = area.create_shape_owner(self)
	area.shape_owner_add_shape(owner_id, shape)
	area.connect("area_entered", self, "_on_entered", [true])
	area.connect("body_entered", self, "_on_entered", [false])
	area.connect("area_exited", self, "_on_exited", [true])
	area.connect("body_exited", self, "_on_exited", [false])
	add_child(area)

func _on_entered(obj, is_area):
	print("found")
	emit_signal("found", obj, is_area)

func _on_exited(obj, is_area):
	print("lost")
	emit_signal("lost", obj, is_area)

func _draw():
	_draw_cone()

func _draw_cone():
	if not (Engine.editor_hint or cone_is_visible):
		return
	
	var colors = PoolColorArray()
	var points = self.cone_points
	
	colors.append(ColorN("green", 0.35))
	
	draw_polygon(points, colors)
