tool
extends Resource

export var minv = 0.0
export var maxv = 1.0
export var incs = 0.2
export var decs = -0.2
export var value = 0.0
export(float, EASE) var easing = 1.0

var tick = 0

func increase(mul=1, v=incs):
	if value < maxv:
		tick += incs / maxv * mul
#		value = ease(tick, easing) * (maxv - value) + value
		value = ease(tick, easing) * maxv
	else:
		1
	
	value = maxv if value > maxv else value
	value = minv if value < minv else value
#	pass

func decrease(mul=1, v=decs):
	pass

func _physics_process(delta):
	print("oof") 