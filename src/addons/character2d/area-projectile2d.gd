extends Area2D

export(float) var lifetime = 5.0
export(int) var collisions = 1
export(float) var health = 0.0

var container = null
var velocity = Vector2(0, 0)
#var gravity = Vector2(0, 0)
var time = 0
var _offset = null
enum _layers { LAYER_DEFAULT=1, LAYER_PC=2, LAYER_NPC=4, LAYER_TERRAIN=32, LAYER_OBJECT=64, LAYER_PROJECTILE=128 }


signal impacted(target)


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

func _on_collision(target=null):
	impact(target)

func impact(target):
	emit_signal("impacted", target)
	
	if target.get("health"):
		target.health.mod(health)
	
	collisions -= 1
	if collisions == 0:
		die()

func die():
	visible = false
	queue_free()
