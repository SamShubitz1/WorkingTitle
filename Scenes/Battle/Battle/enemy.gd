extends Node2D

var abilities_dictionary: Dictionary = {"Rock" : {"name": "Rock",
"type": "Rock", "damage": 20, "description": "A rock based attack"}, "Paper": {"name": "Paper", "type": "Paper", "damage": 20, "description": "A paper based attack"}, "Scissors": {"name": "Scissors", "type": "Scissors", "damage": 20, "description": "A scissors based attack"} }

var enemy_name: String = "Norman"
var alignment: String = "enemy"
var max_health: int = 80

var abilities: Array = [
	abilities_dictionary["Rock"],
	abilities_dictionary["Paper"],
	abilities_dictionary["Scissors"]
	]
	
