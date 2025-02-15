extends Node2D

var char_name = "Deeno"
var max_health = 100

enum AbilityType{
	ROCK,
	PAPER,
	SCISSORS
}

var abilities_dictionary: Dictionary = {"Rock" : {"name": "Rock",
"type": "Rock", "damage": 20, "description": "A rock based attack"}, "Paper": {"name": "Paper", "type": "Paper", "damage": 20, "description": "A paper based attack"}, "Scissors": {"name": "Scissors", "type": "Scissors", "damage": 20, "description": "A scissors based attack"} }
var items_dictionary = {"Extra Rock": {"name": "Extra Rock", "effect_type": "Rock", "description": "Adds damage to rock attacks", "multiplier": .2}, "Sharpener":{"name": "Sharpener", "effect_type": "Scissors", "description": "Adds damage to scissors attacks", "multiplier": .2}, "Extra Paper":{"name": "Extra Paper", "effect_type": "Paper", "description": "Adds damage to paper attacks", "multiplier": .2}}

var abilities: Array = [abilities_dictionary["Rock"],abilities_dictionary["Paper"],abilities_dictionary["Scissors"]]
var items: Array = [items_dictionary["Extra Rock"], items_dictionary["Sharpener"], items_dictionary["Extra Paper"]]
var items_equipped: Array = []
var buffs: Dictionary = {}

func populate_buffs_array() -> void:
	for i in items_equipped:
		buffs[i.effect_type] = i.multiplier
