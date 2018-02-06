extends Node2D

# Cycle props.
export(int) var cycles = 20
export(float) var period = 1.0
export(float, 0, 1) var span = 0.5
# TODO: add a delay to the beginning of the cycle, as percentage of the period,
# adjusted for span.
# export(float, 0, 1) var delay = 0.0

# Emitter props.
export(int) var amount = 1

# Projectile props.
export(float) var lifetime = 0.5
export(int) var collisions = 1
export var velocity = Vector2(5, 0)
export var gravity = Vector2(0, 0)
export var damage = 0.0

# Projectile scene.
export(PackedScene) var projectile

# Container node.
export(NodePath) var container

var cycle_data = { cycles=cycles, period=period, span=span, count=0, time=0 }
var emit_data = { amount=amount, rate=period / amount * span, count=0, time=0 }
var proj_data = { lifetime=lifetime, collisions=collisions, velocity=velocity, gravity=gravity }


func _ready():
	if projectile:
		projectile = projectile.instance(PackedScene.GEN_EDIT_STATE_INSTANCE)
	elif get_child_count():
		projectile = get_child(0)
		remove_child(projectile)
	
	container = get_node(container) if container else self

func _physics_process(delta):
	var c = cycle_data
	var e = emit_data
	
	if active:
		if c.cycles < 0 or (c.cycles != 0 and c.count < c.cycles):
			_cycler(delta)
		else:
			active = false
		
		if e.amount > 0 and e.count < e.amount:
			_emitter(delta)

# TODO: Add a feature to manage when on the clock things should trigger,
# for both _cycler and _emitter. When timing the cycle or the rate, you
# could trigger on the beginning of the timer, the end, or the middle of
# the clock. The first implementation triggered on the falling edge (the end)
# of the clock, but that means there is always a delay when firing.
# The current imp triggers on the rising edge (start), for immediate effect.

func _cycler(delta):
	var c = cycle_data
	var e = emit_data
	
	if c.time == 0:
#		print("cycle")
		e.time = 0
		e.count = 0
	elif c.time >= c.period:
		c.time = 0
		c.count += 1
		return
	
	c.time += delta

func _emitter(delta):
	var e = emit_data
	
	if e.time == 0:
#		print("emit")
		_instance()
	elif e.time >= e.rate:
		e.time = 0
		e.count += 1
		return
	
	e.time += delta

func _instance():
	var p = proj_data
	var n = Projectile2D.new()
	
	for k in proj_data:
		n.set(k, proj_data[k])
	
	n.add_child(projectile.duplicate())
	n.position = container.to_local(to_global(projectile.position))
	container.add_child(n)

func start():
	if active:
		return
	
	reset()
	active = true

func stop():
	if not active:
		return
	
	active = false
	reset()

func reset():
	var c = cycle_data
	var e = emit_data
	
	c.time = 0
	c.count = 0
	e.time = 0
	e.count = 0


class Projectile2D extends Node2D:
	export(float) var lifetime = 5.0
	export(int) var collisions = 1
	export var velocity = Vector2(100, 0)
	export var gravity = Vector2(0, 0)
	export var damage = 0.0
	
	var time = 0
	
	
	func _ready():
#		set_as_toplevel(true)
		pass
	
	func _physics_process(delta):
		time += delta
		
		if time < lifetime:
			position += velocity + gravity * delta
		else:
			queue_free()
