extends MarginContainer

export(NodePath) var player_node
var player = null setget set_player
var res = {}


func set_player(val):
	res["health"] = val.get("health")
	res["energy"] = val.get("energy")
	res["points"] = val.get("points")

	player_name_changed(val.player_name)

	for k in res:
		if res[k]:
			res[k].connect("changed", self, "resource_changed", [k])
			resource_changed({value=res[k].value, mini=res[k].mini, maxi=res[k].maxi}, k)


func _ready():
	pass

func player_name_changed(name):
	var n = find_node("player_name")
	n.text = name

func resource_changed(state, name):
	var n = find_node(name)
	
	if n:
		if n.get("value") != null:
			n.value = state.value
		elif n.get("text") != null:
			n.text = str(state.value)
		if n.get("min_value") != null:
			n.min_value = state.mini
		if n.get("max_value") != null:
			n.max_value = state.maxi
