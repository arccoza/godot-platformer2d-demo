extends Area2D

export var health = 0
export var energy = 0
export var points = 0
var body_resources = ["health", "energy", "points"]

export var interactions_max = -1
var interactions = interactions_max
var bodies = {}

export var period = 0

export var eject = Vector2(0, 0)

export var teleport_on = false
export(NodePath) var teleport_to = null

export var floating_on = false

export var victory_on = false
export var victory_health = -1
export var victory_energy = -1
export var victory_points = -1


signal victory(has_won)
signal teleport_started(body, dest)
signal teleport_ended(body, dest)


func _ready():
	self.connect("body_entered", self, "_on_body_entered")
	self.connect("body_exited", self, "_on_body_exited")

func _physics_process(delta):
	for body in bodies.duplicate():
		var data = bodies[body]
		if data.time >= period:
			body_mod(body)
			data.time = 0
		else:
			data.time += delta
		
		if period == 0:
			bodies.erase(body)

func _on_body_entered(body):
	bodies[body] = {body=body, time=period}

func _on_body_exited(body):
	bodies.erase(body)

func body_mod(body):
	body_mod_resources(body)
	body_is_victory(body)
	body_do_teleport(body)

func body_mod_resources(body):
	for res_name in body_resources:
		var res = body.get(res_name)
		if res:
			res.mod(self.get(res_name))

func body_is_victory(body):
	if not victory_on:
		return
	
	var win = true
	for res_name in body_resources:
		var condition = self.get("victory_" + res_name)
		var res = body.get(res_name)
		if res and res.value < condition:
			win = false
			break
	
	emit_signal("victory", win)
	return win

func body_do_teleport(body):
	if teleport_on and teleport_to:
		var dest = get_node(teleport_to)
		emit_signal("teleport_started", body, dest)
		body.global_position = dest.global_position
		emit_signal("teleport_ended", body, dest)
