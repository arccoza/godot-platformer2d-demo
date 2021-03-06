tool
extends Node2D

export(float) var radius = 100 setget set_radius, get_angle
export(float, 0, 360) var angle = 30 setget set_angle, get_angle
export(Color, RGBA) var color = ColorN("green", 0.35) setget set_color
export(int, 36, 360) var resolution = 72 setget set_resolution
export(bool) var cone_is_visible = false
export(bool) var points_are_visible = false
var cone_points = PoolVector2Array()
var ray_points = PoolVector2Array()
var area = Area2D.new()
var owner_id = null
var shape = ConvexPolygonShape2D.new()
var target = null
var is_target_hittable = false
enum _layers { LAYER_DEFAULT=1, LAYER_PC=2, LAYER_NPC=4, LAYER_TERRAIN=32, LAYER_OBJECT=64, LAYER_PROJECTILE=128 }
export(int, FLAGS, "DEFAULT", "PC", "NPC", "TERRAIN", "OBJECT", "PROJECTILE") var targets = LAYER_PC setget set_targets


func set_targets(val):
	prints("targets:", val)
	targets = val


func set_radius(val):
	radius = val
	draw_cone()

func get_radius(val):
	return radius


func set_angle(val):
	angle = val
	draw_cone()

func get_angle(val):
	return angle


func set_color(val):
	color = val
	update()


func set_resolution(val):
	resolution = val
	draw_cone()


signal found(obj, is_area)  #detected
signal lost(obj, is_area)  #ignored


func _ready():
	shape.points = cone_points
	owner_id = area.create_shape_owner(self)
	area.shape_owner_add_shape(owner_id, shape)
	area.collision_layer = 0
	area.collision_mask = targets
	area.connect("area_entered", self, "_on_entered", [true])
	area.connect("body_entered", self, "_on_entered", [false])
	area.connect("area_exited", self, "_on_exited", [true])
	area.connect("body_exited", self, "_on_exited", [false])
	add_child(area)

func _physics_process(delta):
	var space_state = get_world_2d().direct_space_state
	
	is_target_hittable = false
	if target:
		var hit = space_state.intersect_ray(to_global(position), target.global_position, [self.area])
		draw_ray(position, to_local(target.global_position))
		if hit and hit.collider == target:
			is_target_hittable = true
	else:
		draw_ray(null, null)
	
#	prints(is_target_hittable)

func _on_entered(obj, is_area):
	target = obj
	emit_signal("found", obj, is_area)

func _on_exited(obj, is_area):
	target = null
	emit_signal("lost", obj, is_area)

func draw_cone():
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
	
	cone_points = ps
	update()  # Call update to force a redraw.
	
	return cone_points

func draw_ray(from, to):
	if from != null and to != null:
		ray_points = PoolVector2Array([from, to])
	else:
		ray_points = null
	update()

func _draw():
	_draw_cone()
	_draw_ray()

func _draw_cone():
	if not (Engine.editor_hint or cone_is_visible):
		return
	
	var colors = PoolColorArray()
	var points = cone_points
	
	colors.append(color if color else ColorN("green", 0.35))
	
	if points_are_visible:
		for p in points:
			draw_circle(p, 2.0, colors[0])
	
	draw_polygon(points, colors)

func _draw_ray():
	if ray_points and ray_points.size() >= 2:
#		prints(ray_points)
		draw_line(ray_points[0], ray_points[1], ColorN("red", 0.35), 2.0, false)
