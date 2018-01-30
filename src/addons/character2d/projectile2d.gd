extends Node2D


var node = null
var lifetime = 0
var velocity = Vector2(0, 0)
var gravity = Vector2(0, 0)
var test = 10

func _init(options, n):
	for key in ["lifetime", "velocity", "gravity"]:
		set(key, options[key])
#	print(self)
	node = n
	add_child(n)

func process(delta):
	print("update")
	if lifetime > 0:
		node.position += (velocity + gravity) * delta
	else:
		visible = false
#			queue_free()
	lifetime -= delta