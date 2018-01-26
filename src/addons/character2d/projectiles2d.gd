extends Node2D

export(int) var count = 1
export(float) var lifetime = 1.0
export(int) var cycles = -1
export var velocity = Vector2(100, 0)
export var gravity = Vector2(0, 0)
export(PackedScene) var projectile

var defaults = {count=count, lifetime=lifetime, cycles=cycles, velocity=velocity, gravity=gravity}
var options = defaults
var cycle = 0
var firing = true

func _ready():
	if projectile:
		projectile = projectile.instance(PackedScene.GEN_EDIT_STATE_INSTANCE)
	elif get_child_count():
		projectile = get_child(0)
		remove_child(projectile)

func _physics_process(delta):
	if firing and cycles < 0 or cycle < cycles:
		if get_child_count() < count:
			add_child(_instance(options))
		
		for c in get_children():
			c.update(delta)
		

func _instance(state):
	return Projectile.new(state, projectile.duplicate())

func fire(opts=null):
	options = merge(defaults.duplicate(), opts) if opts else defaults
	firing = true

static func merge(target, patch):
	for key in patch:
		target[key] = patch[key]
	return target


class Projectile extends Node2D:
	var node = null
	var state = {lifetime=0, velocity=Vector2(0, 0), gravity=Vector2(0, 0)}
	
	func _init(s, n):
		state = merge(state, s)
		node = n
		add_child(n)
	
	func update(delta):
		if state.lifetime > 0:
			node.position += (state.velocity + state.gravity) * delta
		else:
			queue_free()
		state.lifetime -= delta
	
	static func merge(target, patch):
		for key in patch:
			target[key] = patch[key]
		return target
