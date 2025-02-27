extends Node2D

var enemy_name: String = "Norman"
var alignment: String = "enemy"
var max_health: int = 80

var abilities: Array = [
	GameData.abilities["Rock"],
	GameData.abilities["Paper"],
	GameData.abilities["Scissors"]
	]
	
