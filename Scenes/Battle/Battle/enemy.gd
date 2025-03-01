extends Node2D

var char_name: String = "Norman"
var max_health: int = 80
var health: ProgressBar

var grid_position: Vector2i

var abilities: Array = [
	GameData.abilities["Rock"],
	GameData.abilities["Paper"],
	GameData.abilities["Scissors"]
	]

func set_health(health_bar: ProgressBar) -> void:
	health = health_bar
	health.max_value = max_health

func take_damage(damage: int) -> void:
	health.value -= damage
