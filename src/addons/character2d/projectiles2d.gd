extends Node2D

export(int) var count = 10
export(int) var cycles = -1
export(float) var period = 1.0
export(float, 0, 1) var delay = 1.0
export(float) var lifetime = 5.0
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
var cycle = Node2D.new()


func _ready():
	if projectile:
		projectile = projectile.instance(PackedScene.GEN_EDIT_STATE_INSTANCE)
	elif get_child_count():
		projectile = get_child(0)
		remove_child(projectile)
	print(options.rate)
	add_child(cycle)

func _physics_process(delta):
	if firing:
		_emit_process(delta)

func _emit_process(delta):
	if (options.cycles > 0 and cycle_count >= options.cycles) or options.cycles == 0:
		firing = false
		return
	
	for c in get_children():
		var should_free = true
		for cc in c.get_children():
			if cc.visible:
				cc.update(delta)
				should_free = false
		if should_free and c.get_child_count():
			remove_child(c)
			c.free()
	
	if cycle_time >= options.period:
		cycle_time = 0
		emit_time = 0
		cycle_count += 1 if options.cycles > 0 else 0
		emit_count = 0
		cycle = Node2D.new()
		add_child(cycle)
		return
	
	cycle_time += delta
	
	if emit_count >= options.count:
		return
	
	emit_time += delta
	
	if options.rate == 0:
		for i in range(0, options.count - emit_count):
			emit_count += 1
			cycle.add_child(_instance(options))
		emit_time = 0
	elif emit_time >= options.rate:
		cycle.add_child(_instance(options))
		emit_time -= options.rate
		emit_count += 1

func _instance(o):
	# TODO: Recycle projectile nodes,
	# rather than constantly creating and destroying them.
	# Also manage the creation, reuse, and destruction better.
	# The flicker is caused by queue_free.
	var p = projectile.duplicate()
	return Projectile2D.new(o.lifetime, o.velocity, o.gravity, p)

func fire(opts=null):
	options = merge(defaults.duplicate(), opts) if opts else defaults
	firing = true

static func merge(target, patch):
	for key in patch:
		target[key] = patch[key]
	return target


# TODO: Create a Cycle2D node to manage cycles and batch projectile removal.

class Projectile2D extends Node2D:
	var node = null
	var lifetime = 0
	var velocity = Vector2(0, 0)
	var gravity = Vector2(0, 0)
	
	func _init(l, v, g, n):
		node = n
		lifetime = l
		velocity = v
		gravity = g
		add_child(n)
	
	func update(delta):
		if lifetime > 0:
			node.position += (velocity + gravity) * delta
		else:
			visible = false
#			queue_free()
		lifetime -= delta
