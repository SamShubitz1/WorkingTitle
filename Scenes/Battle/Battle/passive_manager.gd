extends Node

var current_players: Array
var move_history: Dictionary

func register_players(players: Array) -> void:
	current_players = players
	
func remove_player(target: Character) -> void:
	current_players = current_players.filter(func(p): return p.battle_id != target.battle_id)
