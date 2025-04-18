extends Node2D

var data: Dictionary

func init(battle_data: Dictionary):
	data = battle_data

func get_battle_data() -> Dictionary:
	return data
