tool
extends EditorPlugin


func _enter_tree():
	# Initialization of the plugin goes here
	add_custom_type("Character2D", "KinematicBody2D", preload("character2d.gd"), preload("character2d.png"))

func _exit_tree():
	# Clean-up of the plugin goes here
	pass