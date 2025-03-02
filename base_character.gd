extends Node

class_name Character

var char_name: String
var max_health: int
var health: ProgressBar

var items: Array[Dictionary]
var items_equipped: Array[String]

var grid_position: Vector2i

var abilities: Array = [
	GameData.abilities["Rock"],
	GameData.abilities["Paper"],
	GameData.abilities["Scissors"]
	]
	
var attributes = {"Strength": 1, "Flux": 1, "Armor": 1, "Shielding": 1, "Memory": 1, "Power": 1, "Optics": 1, "Mobility": 1}

func set_health(health_bar: ProgressBar) -> void:
	health = health_bar
	health.max_value = max_health

func take_damage(damage: int) -> void:
	health.value -= damage
