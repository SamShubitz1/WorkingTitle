extends BaseNPC

var flag = {"name": "egg_charger_greeted"}

func update_tree() -> Dictionary:
	PlayerFlags.flags[flag.name] = true
	var tree = super.update_tree()
	return tree
 
