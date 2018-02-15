extends KinematicBody2D
var CharacterMeter = preload("character-meter.gd")
var Projectiles2D = preload("projectiles2d.gd")

export var gravity = Vector2(0, 1000)
export var step_up = Vector2(300, 990)
export var floor_angle_max = 45
export var speed_min = Vector2(10, 6)
export var speed_max = Vector2(220, 2000)
export var speed_inc = Vector2(0.4, 0.8)
export var speed_dec = Vector2(0.1, 1)
export var boost_mul = Vector2(4, 2)
export var health = 100
var health_min = 0
export var health_max = 100
export var energy = 100
var energy_min = 0
export var energy_max = 100

var action = { attack = false, boost = false, left = false, right = false, up = false, down = false }
var boost = Vector2(1, 1)
const boost_reset = Vector2(1, 1)
var direction = Vector2(0, 0)
var direction_last = Vector2(1, 0)
var speed = Vector2(0, 0)
var velocity = Vector2(0, 0)
var floor_normal = Vector2(0, -1)
var floor_angle = deg2rad(floor_angle_max)
var y_time = 0.2
var y_timer = y_time
var sprite = null
var anim = null
var proj = null


func _ready():
	# Get integral child nodes if they exists.
	for c in get_children():
		if c is Sprite:
			sprite = c
		if c is AnimationPlayer:
			anim = c
		if c is Projectiles2D:
			proj = c

	play("idle")
	connect("boost_on", self, "_on_boost")
	connect("boost_off", self, "_on_boost")
	connect("meter_limit", self, "_on_meter_limit")

func _process(delta):
	pass

func _physics_process(delta):
	upd_action(delta)
	upd_direction()
	upd_speed(delta)
	upd_velocity(delta)
	_move(delta)
	
	# Update energy.
	meter("energy", (-1 if action.boost else 1) * 100 * delta)
	
	# Handle animation changes.
	if health <= health_min:
		die()
	elif action.attack:
		attack()
	elif direction.x:
		# Flip $StepLimit RayCast when the character changes direction.
		if $StepLimit:
			$StepLimit.cast_to.x = sign(direction.x) * abs($StepLimit.cast_to.x)
		walk()
	else:
		idle()

func _on_meter_limit(what, upper, value):
	if what == "energy" and not upper:
		_on_boost(false)

func _on_boost(boosted):
	if boosted and energy > energy_min:
		boost = boost_mul
	else:
		boost = boost_reset

func _move(delta):
	velocity = move_and_slide(velocity, floor_normal, 5, 4, floor_angle)
	
	# Modify the characters movements on a slope or stairs.
	var collision = null
	var collision_count = get_slide_count()
	
	if collision_count:
		collision = get_slide_collision(collision_count - 1)
	
	if collision:
		var angle = abs(collision.normal.angle_to(floor_normal))
		if angle <= floor_angle:
			var rem = -gravity.slide(collision.normal) * delta
			if not test_move(self.transform, rem):
				self.position += rem
		elif $StepLimit:
			if not $StepLimit.is_colliding():
				self.position += step_up * Vector2(direction.x, -1) * delta
	
	# Handle jumping.
	if is_on_floor():
		y_timer = y_time
	else:
		y_timer -= delta
		y_timer = clamp(y_timer, 0, y_time)

signal boost_on(boosted)
signal boost_off(boosted)

func upd_action(delta):
	var boost_prev = action.boost
	
	action.left = Input.is_action_pressed("ui_left")
	action.right = Input.is_action_pressed("ui_right")
	action.up = Input.is_action_pressed("ui_up")
	action.down = Input.is_action_pressed("ui_down")
	action.boost = Input.is_action_pressed("player_boost")
	action.attack = Input.is_action_pressed("player_attack")
	
	if action.boost > boost_prev:
		emit_signal("boost_on", action.boost)
	elif action.boost < boost_prev:
		emit_signal("boost_off", action.boost)
	
	return action

func upd_direction():
	direction.x = int(action.right) - int(action.left)
	direction.y = int(action.down) - int(action.up)
	direction_last.x = direction.x if direction.x else direction_last.x
	direction_last.y = direction.y if direction.y else direction_last.y
	return direction

func upd_speed(delta):
	if direction.x:
		speed.x = lerp(speed.x, speed_max.x, speed_inc.x)
		speed.x = clamp(speed.x, speed_min.x, speed_max.x)
	else:
		speed.x = lerp(speed.x, 0, speed_dec.x)
	if direction.y and y_timer > 0:
		speed.y = lerp(speed.y, speed_max.y, speed_inc.y)
#		speed.y += speed_max.y * speed_inc.y
		speed.y = clamp(speed.y, speed_min.y, speed_max.y)
	else:
		speed.y = 0
	return speed

func upd_velocity(delta):
	var v = direction * speed * boost + gravity
	velocity.x = lerp(velocity.x, v.x, 1)
	velocity.y = lerp(velocity.y, v.y, 1)
	return velocity

func idle():
	play("idle")

func walk():
	play("walk")

func die():
	play("die")

func attack():
	play("attack")
	$Projectiles2D.start()

func play(id):
#	print(anim.current_animation_position, " - ",  anim.current_animation_length)
	if sprite:
		sprite.flip_h = true if direction_last.x < 0 else false
	if proj:
		proj.direction = Vector2(direction_last.x, 0)
	if not anim or anim.assigned_animation == id:
		return
	anim.play(id)


class Span extends Resource:
	export(float) var mini = 0.0
	export(float) var maxi = 1.0
	export(float) var incr = 1.0
	export(float) var decr = 1.0
#	export(float) var step = 0.0
#	export(float, 0, 1) var rand = 0.0
#	export(float) var ratio


class SpanCurves extends Resource:
	export var inc = 0
	export var dec = 0


class Quant extends Span:
	export var value = 0.0
	
	signal limit(value, maxed)
	
	func set_value(val):
		var d = val - value
		mod(d)
	
	func _init(v=null):
		value = v
	
	func mod(amount):
		var v = value
		var vmin = mini
		var vmax = maxi
		
		v += amount
		
		if v >= vmax:
			v = vmax
			emit_signal("limit", v, v == vmax)
		elif v <= vmin:
			v = vmin
			emit_signal("limit", v, v == vmax)
		
		value = v
