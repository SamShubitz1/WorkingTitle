extends Node2D

var char_name = "Deeno"
var max_health = 100
var health: ProgressBar

var grid_position: Vector2i

enum AbilityType {
	ROCK,
	PAPER,
	SCISSORS
}

var abilities: Array = [GameData.abilities["Rock"],GameData.abilities["Paper"],GameData.abilities["Scissors"]]
var items: Array = [GameData.items["Extra Rock"], GameData.items["Sharpener"], GameData.items["Extra Paper"]]
var items_equipped: Array = []
var buffs: Dictionary = {}

func populate_buffs_array() -> void:
	for i in items_equipped:
		buffs[i.effect_type] = i.multiplier

func set_health(health_bar: ProgressBar) -> void:
	health = health_bar
	health.max_value = max_health

func take_damage(damage: int) -> void:
	health.value -= damage
