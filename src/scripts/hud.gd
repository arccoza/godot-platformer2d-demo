extends MarginContainer

export(NodePath) var player_node
var player = null
var res = {}


func _ready():
	if player_node:
		player = get_node(player_node)
		res["health"] = player.get("health")
		res["energy"] = player.get("energy")
		res["points"] = player.get("points")
		
		player_name_changed(player.player_name)
		
		for k in res:
			if res[k]:
				res[k].connect("changed", self, "resource_changed", [k])
				resource_changed(res[k].value, k)

# TODO: add code to handle max and min bounds if different between hud and character.
# May have to add a new signal to Quant for when bounds change (eg. max increased).

func player_name_changed(name):
	var n = find_node("player_name")
	n.text = name

func resource_changed(value, name):
	var n = find_node(name + "_bar")
	
	if n:
		n.value = value