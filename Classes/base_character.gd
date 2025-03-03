extends Node

class_name Character

var char_name: String
var max_health: int
var health: ProgressBar

var attributes = {"Strength": 10, "Flux": 10, "Armor": 10, "Shielding": 10, "Memory": 10, "Power": 10, "Optics": 10, "Mobility": 10}

var items: Array[Dictionary]
var abilities: Array
var items_equipped: Array
var status_effects: Array
var buffs: Dictionary
	
var grid_position: Vector2i

func init(char_name: String, health: ProgressBar, max_health: int, abilities: Array, grid_position: Vector2i, items: Array = []):
	self.char_name = char_name
	self.health = health
	self.max_health = max_health
	self.items = items
	self.abilities = abilities
	set_grid_position(grid_position)

func set_grid_position(grid_position: Vector2i):
	self.grid_position = grid_position

func take_damage(damage: int) -> void:
	health.value -= damage
	if health.value <= 0:
		return 

func populate_buffs_array() -> void:
	for i in items_equipped:
		buffs[i.effect_type] = i.multiplier
