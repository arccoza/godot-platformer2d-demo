extends 'character2d.gd'
var VisionCone2D = preload("vision-cone2d.gd")

export(int) var wander_period = 3
export(float, 0, 1, 0.05) var wander_pause = 0.5
var wander_time = 0
export(int) var alert_delay = 2
var alert_time = 0
var alert = false
var vision_cone = null
var rays = []


func _ready():
	for c in get_children():
		if c is VisionCone2D:
			vision_cone = c
	
	_init_vision()
	_init_rays()
	upd_ai_times(0)

func _init_vision():
	if not vision_cone:
		return
	vision_cone.connect("found", self, "_on_vision_detect", [true])
	vision_cone.connect("lost", self, "_on_vision_detect", [false])

func _init_rays():
	for c in get_children():
		if c is RayCast2D:
			rays.append(c)
	
	for r in rays:
		if vision_cone:
			r.add_exception(vision_cone.area)
		for r2 in rays:
			r.add_exception(r2)

func _physics_process(delta):
	upd_ai_times(delta)

func _on_vision_detect(ev, is_area, entered):
	if ev.is_in_group("player"):
		alert = entered
#		print(ev.name, alert)

func upd_ai_times(delta):
	if wander_time <= 0:
		wander_time = rand_range(0, wander_period)
	else:
		wander_time -= delta
	
	if alert_time <= 0 and not alert:
		alert_time = rand_range(0, alert_delay)
	elif alert:
		alert_time -= delta
#	print(alert_time)

func upd_action(delta):
	var _action = {
		left = null,
		right = null,
		up = false,
		down = false,
		boost = false,
		attack = alert and alert_time <= 0
	}
	
	if wander_time <= 0 and not _action.attack:
		var r = randf()
		var gap = (1 - wander_pause) / 2
		_action.left = true if r < gap else false
		_action.right = true if r > 1 - gap else false
	elif _action.attack:
		_action.left = false
		_action.right = false
		
	merge(action, _action)
	
	var turn = ($bump_detect and $bump_detect.is_colliding()) or ($edge_detect and not $edge_detect.is_colliding())
#	prints(turn)
	if not action.attack and turn:
		if action.left or action.right:
			action.left = not action.left
			action.right = not action.right
	
	return action

func upd_direction(delta):
	.upd_direction(delta)
	if direction.x:
		if vision_cone:
			vision_cone.scale = Vector2(direction.x, 1)
		if $bump_detect:
			$bump_detect.cast_to.x = direction.x * abs($bump_detect.cast_to.x)

func merge(a, b):
	for k in b:
		a[k] = b[k] if b[k] != null else a[k]
	return a
