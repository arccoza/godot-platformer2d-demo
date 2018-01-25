tool
extends EditorPlugin

var CharacterMeter = preload("character-meter.gd")
var Character2D = preload("character2d.gd")
var Missile2D = preload("missile2d.gd")

func _enter_tree():
	# Initialization of the plugin goes here
#	var CharacterMeter = preload("character-meter.gd")
#	var Character2D = preload("character2d.gd")
	add_custom_type("CharacterMeter", "Resource", CharacterMeter, preload("character-meter.png"))
	add_custom_type("Character2D", "KinematicBody2D", Character2D, preload("character2d.png"))
	add_custom_type("Missile2D", "Node2D", Missile2D, preload("missile2d.png"))
	print("Character2D plugin loaded.")

func _exit_tree():
	# Clean-up of the plugin goes here
	pass