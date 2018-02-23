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
		
		for k in res:
			if res[k]:
				res[k].connect("changed", self, "resource_changed", [k])

func resource_changed(value, name):
	var n = find_node(name + "_bar")
	
	if n:
		n.value = value