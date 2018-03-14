tool
extends EditorPlugin

#var CharacterMeter = preload("character-meter.gd")
var Character2D = preload("character2d.gd")
var PlayerCharacter2D = preload("player-character2d.gd")
var NonPlayerCharacter2D = preload("non-player-character2d.gd")
var VisionCone2D = preload("vision-cone2d.gd")
var Projectiles2D = preload("projectiles2d.gd")
var AreaProjectile2D = preload("area-projectile2d.gd")
var Interactable2D = preload("interactable2d.gd")

func _enter_tree():
	add_custom_type("PlayerCharacter2D", "KinematicBody2D", PlayerCharacter2D, preload("icons/character2d.svg"))
	add_custom_type("NonPlayerCharacter2D", "KinematicBody2D", NonPlayerCharacter2D, preload("icons/non-player-character2d.svg"))
	add_custom_type("VisionCone2D", "Node2D", VisionCone2D, preload("icons/vision-cone2d.svg"))
	add_custom_type("Projectiles2D", "Node2D", Projectiles2D, preload("icons/projectiles2d.svg"))
	add_custom_type("AreaProjectile2D", "Area2D", AreaProjectile2D, preload("icons/projectile2d.svg"))
	add_custom_type("Interactable2D", "Area2D", Interactable2D, preload("icons/interactable2d.svg"))
	print("Character2D plugin loaded.")

func _exit_tree():
	# Clean-up of the plugin goes here
	pass