extends KinematicBody2D
var CharacterMeter = preload("character-meter.gd")

export var gravity = Vector2(0, 1000)
export var step_up = Vector2(300, 990)
export var floor_angle_max = 45
export var speed_min = Vector2(10, 6)
export var speed_max = Vector2(220, 2000)
export var speed_inc = Vector2(0.4, 0.8)
export var speed_dec = Vector2(0.1, 1)
export var boost_mul = Vector2(4, 2)
export(Resource) var health
export(Resource) var energy


var action = { boost = false, left = false, right = false, up = false, down = false }
var boost = Vector2(1, 1)
const boost_reset = Vector2(1, 1)
var direction = Vector2(0, 0)
var speed = Vector2(0, 0)
var velocity = Vector2(0, 0)
var floor_normal = Vector2(0, -1)
var floor_angle = deg2rad(floor_angle_max)
var y_time = 0.2
var y_timer = y_time


func _ready():
	$Anim.play("idle")

func _process(delta):
	pass

func _physics_process(delta):
#	print(energy.value)
#	energy.increase(delta)
#	print(energy.tick, " - ", energy.value)
	
	upd_direction()
	upd_speed(delta)
#	upd_energy(delta)
	upd_velocity(delta)
	
	velocity = move_and_slide(velocity, floor_normal, 5, 4, floor_angle)
	
	# Modify the characters movements on a slope or stairs.
	var collision = get_slide_collision(get_slide_count() - 1)
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
	
	# Handle speed boost.
	boost = boost_mul if action.boost and energy.value else boost_reset
	
	# Handle animation changes.
	if health and health.value <= 0:
		die()
	elif direction.x:
		# Flip $StepLimit RayCast when the character changes direction.
		if $StepLimit:
			$StepLimit.cast_to.x = sign(direction.x) * abs($StepLimit.cast_to.x)
		walk()
	else:
		idle()

#var energy_tick = 0
#func upd_energy(delta):
#	if energy < energy_max:
#		energy_tick += energy_inc / energy_max * delta
##		print("--", energy)
#		var res = global.ease(energy, energy_max, energy_tick, [global.IN, global.CUBIC])
##		var res = ease(energy_tick, 2) * (energy_max - energy) + energy
#		print(res, res == 5.0)
#		energy = res
#	else:
#		energy_tick = 0

func upd_direction():
	action.left = Input.is_action_pressed("ui_left")
	action.right = Input.is_action_pressed("ui_right")
	action.up = Input.is_action_pressed("ui_up")
	action.down = Input.is_action_pressed("ui_down")
	action.boost = Input.is_action_pressed("player_boost")
	direction.x = float(action.right) - float(action.left)
	direction.y = float(action.down) - float(action.up)
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
	$Sprite.flip_h = true if direction.x < 0 else false
	play("walk")

func die():
	play("die")

func play(id):
	if not $Anim or $Anim.assigned_animation == id:
		return
	$Anim.play(id)
