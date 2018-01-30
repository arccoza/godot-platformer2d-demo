extends Node2D
var Projectile2D = preload("projectile2d.gd")

export(int) var count = 10
export(int) var cycles = -1
export(float) var period = 1.0
export(float, 0, 1) var delay = 1.0
export(float) var lifetime = 5.0
export var velocity = Vector2(100, 0)
export var gravity = Vector2(0, 0)
export(PackedScene) var projectile

onready var defaults = {
	count=count,
	cycles=cycles,
	period=period,
	delay=delay,
	lifetime=lifetime,
	velocity=velocity,
	gravity=gravity,
	rate = period / count * delay
}
onready var options = defaults
var cycle_count = 0
var cycle_time = 0
var emit_count = 0
var emit_time = 0
var firing = false
var cycle = Node2D.new()

func _init(p):
	pass

func _ready():
	if projectile:
		projectile = projectile.instance(PackedScene.GEN_EDIT_STATE_INSTANCE)
	elif get_child_count():
		projectile = get_child(0)
		remove_child(projectile)
#	print(options.rate)
#	cycle = Cycle2D.new(options, Projectile2D.new(options, projectile))
#	var p = Projectile2D.new(options, projectile)
	var p = Inner2.new("p")
	print(p.get_script())
	p.test = 12
	print(p.test)
	var dup = p.duplicate()
	print(dup.get_script())
#	print(dup.test)
#	add_child(cycle)

func _physics_process(delta):
#	_emit_process(delta)
#	cycle.update(delta)
	pass
	

func _emit_process(delta):
	for c in get_children():
		var should_free = true
		for cc in c.get_children():
			if cc.visible:
				cc.update(delta)
				should_free = false
		if should_free and c.get_child_count():
			print("death")
			remove_child(c)
			c.free()
	
	if (options.cycles > 0 and cycle_count >= options.cycles) or options.cycles == 0:
		firing = false
		return
	
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

func reset():
	cycle_count = 0
	cycle_time = 0
	emit_count = 0
	emit_time = 0

func fire(opts=null):
	reset()
	options = merge(defaults.duplicate(), opts) if opts else defaults
	firing = true

static func merge(target, patch):
	for key in patch:
		target[key] = patch[key]
	return target


# TODO: Create a Cycle2D node to manage cycles and batch projectile removal.
class Cycle2D extends Node2D:
	var Projectile2D = preload("projectile2d.gd")
	var count = 1
	var period = 1.0
	var delay = 1.0
	var rate = period / count * delay
	var emit_time = 0
	var cycle_time = 0
	var emit_count = 0
	var projectile = null
	
	func _init(options, n):
		for key in ["count", "period", "delay"]:
			set(key, options[key])
		rate = period / count * delay
		projectile = n
	
	func update(delta):
		emit(delta)
		
		for c in get_children():
			c.position += Vector2(1, 0)
	
	func emit(delta):
		if emit_count >= count:
			return
	
		emit_time += delta
		
		if rate == 0:
			for i in range(0, count - emit_count):
				emit_count += 1
				add_projectile()
				print("emit")
			emit_time = 0
		elif emit_time >= rate:
			add_projectile()
			print("emit")
			emit_time -= rate
			emit_count += 1
	
	func add_projectile():
		print(projectile.get_script())
		var p = projectile.duplicate(Node.DUPLICATE_SCRIPTS)
		print(p.get_child(0), p.get_child(0).get_child(0))
		print(p)
		add_child(p)


class Inner2 extends Node2D:
	export var test = "Inner2"
	
	func _init(p):
		pass
	
	func hello():
		print("hello fn call")


#class Projectile2D extends Node2D:
#	var node = null
#	var lifetime = 0
#	var velocity = Vector2(0, 0)
#	var gravity = Vector2(0, 0)
#
#	func _init(options, n):
#		for key in ["lifetime", "velocity", "gravity"]:
#			set(key, options[key])
#		print(self)
#		node = n
#		add_child(n)
#
#	func process(delta):
#		print("update")
#		if lifetime > 0:
#			node.position += (velocity + gravity) * delta
#		else:
#			visible = false
##			queue_free()
#		lifetime -= delta
