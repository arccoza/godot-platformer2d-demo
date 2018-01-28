extends Node2D

export(int) var count = 5
export(int) var cycles = -1
export(float) var period = 1.0
export(float, 0, 1) var delay = 0.5
export(float, 0, 1) var lifetime = 1.0
export var velocity = Vector2(100, 0)
export var gravity = Vector2(0, 0)
export(PackedScene) var projectile

var defaults = {
	count=count,
	cycles=cycles,
	period=period,
	delay=delay,
	lifetime=lifetime,
	velocity=velocity,
	gravity=gravity,
	rate = period / count * delay
}
var options = defaults
var cycle_count = 0
var cycle_time = 0
var emit_count = 0
var emit_time = 0
var firing = true


func _ready():
	if projectile:
		projectile = projectile.instance(PackedScene.GEN_EDIT_STATE_INSTANCE)
	elif get_child_count():
		projectile = get_child(0)
		remove_child(projectile)

func _physics_process(delta):
	if firing:
		_emit_process(delta)
	
#	if firing and cycles < 0 or cycle < cycles:
#		if get_child_count() < count:
#			add_child(_instance(options))
#
#		for c in get_children():
#			c.update(delta)

func _emit_process(delta):
	if (options.cycles > 0 and cycle_count >= options.cycles) or options.cycles == 0:
		firing = false
		print("stop")
		return
	
	for c in get_children():
		c.update(delta)
	
	if cycle_time >= options.period:
		cycle_time = 0
		emit_time = 0
		cycle_count += 1 if options.cycles > 0 else 0
		emit_count = 0
		print("cycle")
		return
	
	cycle_time += delta
	
	if emit_count >= options.count:
		return
	
	emit_time += delta
	
	if options.rate == 0 or options.rate < delta:
		for i in range(0, options.count - emit_count):
			emit_count += 1
			print("tick")
			add_child(_instance(options))
		emit_time = 0
	elif emit_time >= options.rate:
		print("tick", " - ", emit_time)
		add_child(_instance(options))
		emit_time -= options.rate
		emit_count += 1

func _instance(state):
	return Projectile2D.new(state, projectile.duplicate())

func fire(opts=null):
	options = merge(defaults.duplicate(), opts) if opts else defaults
	firing = true

static func merge(target, patch):
	for key in patch:
		target[key] = patch[key]
	return target


class Projectile2D extends Node2D:
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
