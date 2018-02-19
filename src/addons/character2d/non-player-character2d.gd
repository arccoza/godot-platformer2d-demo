extends 'character2d.gd'
var VisionCone2D = preload("vision-cone2d.gd")

export(int) var wander_period = 3
export(float, 0, 1, 0.05) var wander_pause = 0.5
var wander_time = 0
export(int) var alert_delay = 2
var alert_time = 0
var alert = false
var vision_cone = null


func _ready():
	for c in get_children():
		if c is VisionCone2D:
			vision_cone = c
	
	_init_vision()
	upd_ai_times(0)

func _init_vision():
	if not vision_cone:
		return
	$step_limit.add_exception(vision_cone)
	vision_cone.connect("found", self, "_on_vision_detect", [true])
	vision_cone.connect("lost", self, "_on_vision_detect", [false])

func _physics_process(delta):
	upd_ai_times(delta)
	if direction.x:
		vision_cone.scale = Vector2(direction.x, 1)

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
	return action

func merge(a, b):
	for k in b:
		a[k] = b[k]
	return a
