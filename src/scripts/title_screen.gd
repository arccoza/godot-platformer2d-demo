extends PanelContainer

export(NodePath) var player_node
var player = null
export(NodePath) var level_node
var level = null
var name_input = null
var start_button = null
var is_restart = false setget set_restart
var spawn_point = null
enum game_states {GAME_STOPPED, GAME_PAUSED, GAME_PLAYING}
enum game_actions {GAME_STOP, GAME_PAUSE, GAME_PLAY, GAME_TOGGLE}
var game_state = GAME_STOPPED
onready var hud = get_node("../hud_screen")


func set_restart(val):
	is_restart = val
	if val:
		pass # trigger restart mode


func _ready():
	get_tree().paused = true
	player = get_node(player_node)
	if player is InstancePlaceholder:
		player.replace_by_instance()
		player = get_node(player_node)
	
	spawn_point = player.position
	
	name_input = find_node("name")
	start_button = find_node("start")
	
	if name_input:
		name_input.connect("text_changed", self, "_on_name_changed")
		name_input.connect("text_entered", self, "_on_start_pressed")
	
	if start_button:
		start_button.connect("pressed", self, "_on_start_pressed")

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		print("esc")
		game_do(GAME_TOGGLE)

func _on_name_changed(t):
	if start_button:
		if t.length() >= 3:
			start_button.disabled = false
		else:
			start_button.disabled = true
		
		player.player_name = t
		hud.find_node("player_name").text = t

func _on_start_pressed(t=null):
	prints(start_button.text)
	if start_button.text.to_upper().ends_with("START"):
		game_do(GAME_PLAY)
	else:
		game_do(GAME_STOP)

func show(val=true):
	get_tree().paused = val
	self.visible = val

func hide():
	show(false)

func game_do(action):
	prints("ACTION")
	var from = game_state
	var to = game_state
	
	match from:
		GAME_STOPPED, GAME_PAUSED:
			match action:
				GAME_PLAY:
					if not start_button.disabled:
						hide()
						start_button.text = "STOP"
						name_input.editable = false
						to = GAME_PLAYING
				GAME_TOGGLE:
					to = game_do(GAME_PLAY)
		GAME_PLAYING:
			match action:
				GAME_PAUSE:
					show()
					to = GAME_PAUSED
				GAME_STOP:
					show()
					start_button.text = "START"
					name_input.clear()
					name_input.editable = true
#					player.
					to = GAME_STOPPED
				GAME_TOGGLE:
					to = game_do(GAME_PAUSE)
					
	print(game_state)
	game_state = to
	return to
