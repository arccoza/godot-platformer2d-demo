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
var animp = null
var proj = null


func _ready():
	# Get integral child nodes if they exists.
	for c in get_children():
		if c is Sprite:
			sprite = c
		if c is AnimationPlayer:
			animp = c
		if c is Projectiles2D:
			proj = c
	
	health = Quant.new(health)
	health.mini = health_min
	health.maxi = health_max
#	health.connect("limited", self, "_on_health_limit")
	
	energy = Quant.new(energy)
	energy.mini = energy_min
	energy.maxi = energy_max
	energy.connect("limited", self, "_on_energy_limit")

	connect("action_changed", self, "_on_action")
	play("idle")
	

#func _process(delta):
#	pass

func _physics_process(delta):
	upd_action(delta)
	upd_direction()
	upd_speed(delta)
	upd_velocity(delta)
#	_move(delta)
	
	# Update energy.
	energy.mod((-1 if action.boost else 1) * 100 * delta)
#	health.mod(-50 * delta)
	
	# Handle animation changes.
	if health.value > health.mini:
		_move(delta)
		if action.attack:
			attack()
		elif direction.x:
			# Flip $StepLimit RayCast when the character changes direction.
			if $StepLimit:
				$StepLimit.cast_to.x = sign(direction.x) * abs($StepLimit.cast_to.x)
			walk()
		else:
			idle()
	else:
		die()

func _on_health_limit(value, maxed):
	if not maxed:
		die()

func _on_energy_limit(value, maxed):
	if not maxed:
		_on_action("boost", false)

func _on_action(name, state):
	if name == "boost" and state and energy.value > energy.mini:
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

signal action_changed(name, state)

func upd_action(delta):
	var _action = {
		left = Input.is_action_pressed("ui_left"),
		right = Input.is_action_pressed("ui_right"),
		up = Input.is_action_pressed("ui_up"),
		down = Input.is_action_pressed("ui_down"),
		boost = Input.is_action_pressed("player_boost"),
		attack = Input.is_action_pressed("player_attack")
	}
	
	for k in _action:
		if _action[k] != action[k]:
			emit_signal("action_changed", k, _action[k])
	
	action = _action
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
	proj.start()

func play(id):
	var current = animp.get_animation(animp.current_animation)
	var interuptable = current and current.loop
	
	if sprite and id != "die":
		sprite.flip_h = true if direction_last.x < 0 else false
	if proj and id != "die":
		proj.direction = Vector2(direction_last.x, 0)
	
	if not animp or animp.assigned_animation == id:
		return
	
	if not current or interuptable:
		animp.play(id)


class Span extends Resource:
	export(float) var mini = 0.0
	export(float) var maxi = 1.0
	export(float) var incr = 1.0
	export(float) var decr = 1.0


class Quant extends Span:
	export var value = 0.0
	
	signal limited(value, maxed)
	
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
		elif v <= vmin:
			v = vmin
		
		if v != value and (v == vmin or v == vmax):
			emit_signal("limited", v, v == vmax)
		
		value = v
