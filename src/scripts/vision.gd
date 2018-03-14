tool
extends Node2D

export(float) var radius = 100
export(float, 0, 360) var angle = 30
export(Color, RGBA) var color = ColorN("green", 0.35)
export(int, 36, 360) var resolution = 72
var shapes = []
var area = Area2D.new()
var owner_id = null
var shape = ConvexPolygonShape2D.new()
var query = Physics2DShapeQueryParameters.new()
var points = PoolVector2Array()

func _ready():
	shape.points = get_cone(angle, radius, resolution)
	shapes.append(shape.points)
#	owner_id = area.create_shape_owner(area)
#	area.shape_owner_add_shape(owner_id, shape)
#	area.connect("area_entered", self, "_on_entered", [true])
#	area.connect("body_entered", self, "_on_entered", [false])
#	area.connect("area_exited", self, "_on_exited", [true])
#	area.connect("body_exited", self, "_on_exited", [false])
#	add_child(area)
	query.set_shape(shape)
	query.collision_layer = 1
	query.transform = self.transform

func _on_entered(obj, is_area):
#	prints(obj)
	pass

func _on_exited(obj, is_area):
	pass

func _physics_process(delta):
	var phys = Physics2DServer
	var space = get_world_2d().direct_space_state
	var res = space.intersect_shape(query, 32)
#	prints(res[0].shape, phys.shape_get_data(phys.body_get_shape(res[0].rid, res[0].shape)), phys.body_get_shape_transform(res[0].rid, res[0].shape))
	prints(res[0].collider.shape_owner_get_shape(0, res[0].shape))
#	points = res

func get_cone(angle, radius, resolution):
	var ang = deg2rad(angle)
	var res = ceil((resolution/360.0) * angle * radius/360)  # Number of points in the arc.
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
	return ps

func _draw():
	var colors = PoolColorArray([color])
	for s in shapes:
		self.call("draw_polygon", s, colors)
	
	for p in points:
		draw_circle(to_local(p), 2.0, ColorN("red", 1.0))
