extends Node2D

# Cycle props.
export(int) var cycles = 2
export(float) var period = 1.0
export(float, 0, 1) var span = 0.5
#export(float, 0, 1) var delay = 0.0
# Emitter props.
export(int) var amount = 5
# Projectile props.
export(float) var lifetime = 0.5
export(int) var collisions = 1
export var velocity = Vector2(5, 0)
export var gravity = Vector2(0, 0)
# Projectile scene.
export(PackedScene) var projectile

var cycle_data = { cycles=cycles, period=period, span=span, count=0, time=0 }
var emit_data = { amount=amount, rate=period / amount * span, count=0, time=0 }
var proj_data = { lifetime=lifetime, collisions=collisions, velocity=velocity, gravity=gravity }


func _ready():
	if projectile:
		projectile = projectile.instance(PackedScene.GEN_EDIT_STATE_INSTANCE)
	elif get_child_count():
		projectile = get_child(0)
		remove_child(projectile)

func _physics_process(delta):
	var c = cycle_data
	var e = emit_data
	
	if c.cycles < 0 or (c.cycles != 0 and c.count < c.cycles):
		_cycler(delta)
	
	if e.amount > 0 and e.count < e.amount:
		_emitter(delta)

func _cycler(delta):
	var c = cycle_data
	var e = emit_data
	
	if c.time == 0:
		print("cycle")
		e.time = 0
		e.count = 0
	elif c.time >= c.period:
		c.time = 0
		c.count += 1
		return
	
	c.time += delta
	
#	if c.time >= c.period:
#		print("cycle")
#		c.time = 0
#		c.count += 1
#		e.time = 0
#		e.count = 0
#	else:
#		c.time += delta

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
	
#	e.time += delta
#
#	if e.time >= e.rate:
#		print("emit")
#		e.time -= e.rate
#		e.count += 1

func _instance():
	var p = proj_data
	var n = Projectile2D.new()
	
	for k in proj_data:
		n.set(k, proj_data[k])
	
	n.add_child(projectile.duplicate())
	add_child(n)
		


class Projectile2D extends Node2D:
	export(float) var lifetime = 5.0
	export(int) var collisions = 1
	export var velocity = Vector2(100, 0)
	export var gravity = Vector2(0, 0)
	var time = 0
	
	func _physics_process(delta):
		time += delta
		
		if time < lifetime:
			position += velocity + gravity * delta
		else:
			queue_free()
