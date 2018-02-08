extends Area2D

export(float) var lifetime = 5.0
export(int) var collisions = 1
export(float) var damage = 0.0

var container = null
var velocity = Vector2(0, 0)
#var gravity = Vector2(0, 0)
var time = 0
var _offset = null


func _prep(data):
	for k in data:
		set(k, data[k])
	
	print(_offset.pos)
	position = container.to_local(_offset.pos)
	_orient()
	container.add_child(self)

func _ready():
	pass

func _orient():
	var v = velocity
	rotation = v.angle() + _offset.rot

func _physics_process(delta):
	time += delta
	
	position += (velocity) * delta
	_orient()
	
	if time >= lifetime:
		queue_free()