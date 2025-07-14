extends Node

var current_players: Array
var move_history: Dictionary

func register_players(players: Array) -> void:
	current_players = players
	for player in current_players:
		if !GameData.passives.has(player.char_name):
			continue
		if GameData.passives[player.char_name].passive_name == "Cascade":
			move_history[player.battle_id] = []
	

func resolve_passive(player: Character, active_passive: String, ability: Dictionary = {}):
	if !GameData.passives.has(player.char_name) || GameData.passives[player.char_name].passive_name != active_passive:
		return
	match GameData.passives[player.char_name].passive_name: 
		"Cascade": 
			resolve_cascade(player, ability.name)
		"Harden":
			resolve_harden(player)
		_:
			return
			
func resolve_cascade(player: Character, ability: String):
	var ability_list = move_history[player.battle_id]
	if ability in ability_list:
		return
	else:
		ability_list.append(ability)
		var effect = {"effect_type": GameData.EffectType.ATTRIBUTE, "property": GameData.Attributes.FLUX, "value": 1, "duration": -1}
		player.resolve_effect(effect)
		#print("It worked ", player.current_attributes[GameData.Attributes.FLUX])

func resolve_harden(player: Character):
	var effect = {"effect_type": GameData.EffectType.ATTRIBUTE, "property": GameData.Attributes.ARMOR, "value": 1, "duration": 1}
	player.resolve_effect(effect)
	print("It worked ", player.current_attributes[GameData.Attributes.ARMOR])

func remove_player(target: Character) -> void:
	current_players = current_players.filter(func(p): return p.battle_id != target.battle_id)
