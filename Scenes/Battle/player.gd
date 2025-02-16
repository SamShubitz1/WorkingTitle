extends Node2D

var char_name = "Deeno"
var max_health = 100

enum AbilityType {
	ROCK,
	PAPER,
	SCISSORS
}

var abilities_dictionary: Dictionary = {"Rock" : {"name": "Rock",
"type": "Rock", "damage": 20, "description": "A rock based attack"}, "Paper": {"name": "Paper", "type": "Paper", "damage": 20, "description": "A paper based attack"}, "Scissors": {"name": "Scissors", "type": "Scissors", "damage": 20, "description": "A scissors based attack"} }
var items_dictionary: Dictionary = {"Extra Rock": {"name": "Extra Rock", "effect_type": "Rock", "effect_description": "Rock attack went up!", "menu_description": "Adds damage to rock attacks", "multiplier": .3}, "Sharpener":{"name": "Sharpener", "effect_type": "Scissors", "effect_description": "Scissors attack went up!", "menu_description": "Adds damage to scissors attacks", "multiplier": .3}, "Extra Paper":{"name": "Extra Paper", "effect_type": "Paper", "effect_description": "Paper attack went up!", "menu_description": "Adds damage to paper attacks", "multiplier": .3}}

var abilities: Array = [abilities_dictionary["Rock"],abilities_dictionary["Paper"],abilities_dictionary["Scissors"]]
var items: Array = [items_dictionary["Extra Rock"], items_dictionary["Sharpener"], items_dictionary["Extra Paper"]]
var items_equipped: Array = []
var buffs: Dictionary = {}

func populate_buffs_array() -> void:
	for i in items_equipped:
		buffs[i.effect_type] = i.multiplier
