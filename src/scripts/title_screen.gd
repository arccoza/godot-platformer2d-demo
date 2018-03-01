extends PanelContainer

export(NodePath) var player_node
var player = null
export(NodePath) var level_node
var level = null
var name_input = null
var start_button = null
var is_restart = false setget set_restart


func set_restart(val):
	is_restart = val
	if val:
		pass # trigger restart mode


func _ready():
	name_input = find_node("name")
	start_button = find_node("start")
	
	if name_input:
		name_input.connect("text_changed", self, "_on_name_changed")
		name_input.connect("text_entered", self, "_on_start_pressed")
	
	if start_button:
		start_button.connect("pressed", self, "_on_start_pressed")

func _on_name_changed(t):
	if start_button:
		if t.length() >= 3:
			start_button.disabled = false
		else:
			start_button.disabled = true

func _on_start_pressed(t=null):
	if name_input and name_input.text.length() >= 3:
		prints("start")
