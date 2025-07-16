extends Node

var current_players: Array
var move_history: Dictionary
			
func resolve_passive(player: Character, active_passive: String, ability: Dictionary = {}):
	if player.passive.name != active_passive:
		return
		
	match active_passive:
		"Hop":
			player.resolve_effect(player.passive)
		"Cascade":
			resolve_cascade(player, ability)
		"Thorn":
			player.resolve_effect(player.passive)
			
func resolve_cascade(player: Character, ability: Dictionary):
	var ability_list = move_history[player.battle_id]
	if ability.name in ability_list:
		return
	else:
		ability_list.append(ability)
		player.resolve_effect(player.passive)

func remove_player(target: Character) -> void:
	current_players = current_players.filter(func(p): return p.battle_id != target.battle_id)

func register_players(players: Array) -> void:
	current_players = players
	for player in current_players:
		if player.passive.name == "Cascade":
			move_history[player.battle_id] = []
