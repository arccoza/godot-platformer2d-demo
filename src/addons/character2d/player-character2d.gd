extends "character2d.gd"

export var player_name = "Bob"

export var points_value = 100
var points_min = 0
export var points_max = 100
var points = Quant.new(points_value, points_min, points_max)


func _ready():
	pass

