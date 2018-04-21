extends PanelContainer

export(NodePath) var player_node
var player = null
export(NodePath) var level_node
var level_scene = null
var level = null
var level_finish = null
var name_input = null
var start_button = null
enum game_states {GAME_STOPPED, GAME_PAUSED, GAME_PLAYING, GAME_FINISHED}
enum game_actions {GAME_STOP, GAME_PAUSE, GAME_PLAY, GAME_TOGGLE, GAME_VICTORY}
var game_state = GAME_STOPPED
onready var hud = get_node("../hud_screen")
onready var vic = get_node("../victory_screen")
onready var vic_win = vic.find_node("win")
onready var vic_lose = vic.find_node("lose")


func _ready():
	get_tree().paused = true
	
	level = get_node(level_node)
	level_scene = load(level.get_instance_path())
	yield(get_tree(), "idle_frame")  # Wait here for the tree to finish building before we make changes.
	level.replace_by_instance()
	level = get_node(level_node)
	
	level_finish = level.find_node("finish")
	
	player = level.find_node("player")
	hud.player = player
	
	name_input = find_node("name")
	start_button = find_node("start")
	
	if level_finish:
		level_finish.connect("victory", self, "_on_victory")
	
	if name_input:
		name_input.connect("text_changed", self, "_on_name_changed")
		name_input.connect("text_entered", self, "_on_start_pressed")
	
	if start_button:
		start_button.connect("pressed", self, "_on_start_pressed")

func _on_victory(won):
	game_do(GAME_VICTORY, won)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
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
	if start_button.text.to_upper().ends_with("START"):
		game_do(GAME_PLAY)
	else:
		game_do(GAME_STOP)

func pause(val=true):
	get_tree().paused = val

func show(val=true):
	pause(val)
	self.visible = val

func hide():
	show(false)

func reset_game():
	var old = level
	var parent = old.get_parent()
	old.name += "_"
	old.queue_free()
	level = level_scene.instance()
	parent.add_child_below_node(old, level, true)
	level_finish = level.find_node("finish")
	player = level.find_node("player")
	hud.player = player
	
	if level_finish:
		level_finish.connect("victory", self, "_on_victory")
	
	start_button.text = "START"
	name_input.clear()
	name_input.editable = true
	
	for c in player.get_children():
		if c is Camera2D:
			c.make_current()
			break

func game_do(action, data=null):
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
				GAME_STOP:
					show()
					reset_game()
					to = GAME_STOPPED
				GAME_TOGGLE:
					to = game_do(GAME_PLAY)
		GAME_PLAYING:
			match action:
				GAME_PAUSE:
					show()
					to = GAME_PAUSED
				GAME_VICTORY:
					pause()
					var won = data
					vic.visible = true
					vic_win.visible = won
					vic_lose.visible = not won
					to = GAME_FINISHED
				GAME_TOGGLE:
					to = game_do(GAME_PAUSE)
		GAME_FINISHED:
			match action:
				GAME_TOGGLE:
					to = game_do(GAME_STOP)
				GAME_STOP:
					vic.visible = false
					show()
					reset_game()
					to = GAME_STOPPED
	
	game_state = to
	return to
