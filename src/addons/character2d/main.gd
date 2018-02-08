tool
extends EditorPlugin

var CharacterMeter = preload("character-meter.gd")
var Character2D = preload("character2d.gd")
var Projectiles2D = preload("projectiles2d.gd")
var AreaProjectile2D = preload("area-projectile2d.gd")

func _enter_tree():
	# Initialization of the plugin goes here
#	var CharacterMeter = preload("character-meter.gd")
#	var Character2D = preload("character2d.gd")
	add_custom_type("CharacterMeter", "Resource", CharacterMeter, preload("icons/character-meter.png"))
	add_custom_type("Character2D", "KinematicBody2D", Character2D, preload("icons/character2d.png"))
	add_custom_type("Projectiles2D", "Node2D", Projectiles2D, preload("icons/projectiles2d.png"))
	add_custom_type("AreaProjectile2D", "Area2D", AreaProjectile2D, preload("icons/projectiles2d.png"))
	print("Character2D plugin loaded.")

func _exit_tree():
	# Clean-up of the plugin goes here
	pass