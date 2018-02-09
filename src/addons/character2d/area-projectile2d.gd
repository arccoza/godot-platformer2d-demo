extends Area2D

export(float) var lifetime = 5.0
export(int) var collisions = 1
export(String, MULTILINE) var collision_groups = "terrain\nenemy" setget set_collision_groups, get_collision_groups
export(float) var damage = 0.0

var container = null
var velocity = Vector2(0, 0)
#var gravity = Vector2(0, 0)
var time = 0
var _offset = null

func set_collision_groups(val):
	match typeof(val):
		TYPE_STRING:
			collision_groups = val.split("\n")
		TYPE_ARRAY:
			collision_groups = PoolStringArray(val)
		TYPE_STRING_ARRAY:
			collision_groups = val

func get_collision_groups():
	return collision_groups


func _prep(data):
	for k in data:
		set(k, data[k])
	
	position = container.to_local(_offset.pos)
	_orient()
	container.add_child(self)

func _ready():
	connect("area_entered", self, "_on_collision")
	connect("body_entered", self, "_on_collision")

func _orient():
	var v = velocity
	rotation = v.angle() + _offset.rot

func _physics_process(delta):
	time += delta
	
	position += (velocity) * delta
	_orient()
	
	if time >= lifetime:
		die()

func _on_collision(ev=null):
	var target_groups = ev.get_groups()
	for cg in collision_groups:
		if cg in target_groups:
			die()

func die():
	visible = false
	queue_free()
