extends Node2D

var time = 0


func _ready():
	pass

func _physics_process(delta):
	time += delta
	
	if time > 5:
		shape_owner_set_disabled(0, true)
