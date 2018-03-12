extends Area2D

export(int, FLAGS, 'Character2D', 'Npc2D') var targets = 1
export(float, -1, 1, 0.01) var health = 0.0
export(int, -1000000, 1000000) var points = 0
export var ttl = -1
export(int, 0, 1000000) var period = 0
var period_cur = 0
var bodies = {}
export var eject = Vector2(0, 0)
export(NodePath) var teleport_to = null
export var victory = false
export var victory_health = 0
export var victory_points = 0
var win_ui = null
var lose_ui = null
const Interact2D = true

func _ready():
	pass
