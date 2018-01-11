extends KinematicBody2D

export var gravity = Vector2(0, 500)
export var speed_min = Vector2(10, 6) 
export var speed_max = Vector2(220, 1200)
export var speed_boost = Vector2(2, 1)
export var speed_accel = Vector2(0.4, 0.8)

var direction = Vector2(0, 0)
var speed = Vector2(0, 0)
var velocity = Vector2(0, 0)
var floor_normal = Vector2(0, -1)
var y_time = 0.2
var y_timer = y_time


func _ready():
	$Anim.play("idle")
	pass

func _process(delta):
	pass

func _physics_process(delta):
	upd_direction()
	upd_speed(delta)
	print(speed)
	upd_velocity()
	var has_direction = direction.x or direction.y
#	self.position += velocity * delta
	move_and_slide(velocity, floor_normal)
	
	if is_on_floor():
		y_timer = y_time
	else:
		y_timer -= delta
		y_timer = clamp(y_timer, 0, y_time)
	
	if direction.x:
		walk()
	else:
		idle()

func upd_direction():
	direction.x = float(Input.is_action_pressed("ui_right")) - float(Input.is_action_pressed("ui_left"))
	direction.y = float(Input.is_action_pressed("ui_down")) - float(Input.is_action_pressed("ui_up"))
	return direction

func upd_speed(delta):
	if direction.x:
		speed.x = lerp(speed.x, speed_max.x, speed_accel.x)
		speed.x = clamp(speed.x, speed_min.x, speed_max.x)
	else:
		speed.x = 0
	if direction.y and y_timer > 0:
		speed.y = lerp(speed.y, speed_max.y, speed_accel.y)
		speed.y = clamp(speed.y, speed_min.y, speed_max.y)
	else:
		speed.y = 0
	return speed

func upd_velocity():
	velocity = direction * speed + gravity
	return velocity

func idle():
	if $Anim.get_current_animation() != "idle":
		$Anim.set_current_animation("idle")

func walk():
	$Sprite.flip_h = true if direction.x < 0 else false
	if $Anim.get_current_animation() != "walk":
		$Anim.set_current_animation("walk")
	if not $Anim.is_playing():
#		print("play")
#		$Anim.set_current_animation("walk")
		$Anim.play()