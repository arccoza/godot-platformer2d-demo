extends 'character2d.gd'

export(int) var wander_period = 3
export(float, 0, 1, 0.05) var wander_pause = 0.5
var wander_time = 0
export(int) var alert_delay = 2
var alert_time = 0

var alert = false
var vision = null


func _ready():
	vision = $vision
	$step_limit.add_exception(vision)
	vision.connect("body_entered", self, "_on_vision_detect", [true])
	vision.connect("body_exited", self, "_on_vision_detect", [false])
	upd_ai_times(0)

func _physics_process(delta):
	upd_ai_times(delta)
	if direction.x:
		vision.scale = Vector2(direction.x, 1)

func _on_vision_detect(ev, entered):
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
