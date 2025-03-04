extends Node

class_name Character

var char_name: String
var alliance: GameData.Alliance
var max_health: int
var is_player: bool = false

var health_bar: ProgressBar
var sprite: AnimatedSprite2D

var attributes = {"Strength": 10, "Flux": 10, "Armor": 10, "Shielding": 10, "Memory": 10, "Power": 10, "Optics": 10, "Mobility": 10}

var items: Array
var abilities: Array
var items_equipped: Array
var status_effects: Array
var buffs: Dictionary
	
var grid_position: Vector2i

func init(char_name: String, char_alliance: GameData.Alliance, char_sprite: AnimatedSprite2D, char_health: ProgressBar, max_health: int, abilities: Array, grid_position: Vector2i, items: Array = []):
	self.char_name = char_name
	self.alliance = char_alliance
	self.sprite = char_sprite
	self.health_bar = char_health
	self.max_health = max_health
	set_health()
	set_abilities(abilities)
	set_items(items)
	set_grid_position(grid_position)
	sprite.play()

func set_grid_position(grid_position: Vector2i):
	self.grid_position = grid_position
	
func set_health() -> void:
	health_bar.max_value = max_health
	health_bar.value = max_health
		
func set_abilities(abilities: Array) -> void:
	var char_abilities: Array
	for ability in abilities:
		char_abilities.append(GameData.abilities[ability])
	self.abilities = char_abilities

func set_items(items: Array) -> void:
	var char_items: Array
	for item in items:
		char_items.append(GameData.items[item])
	self.items = char_items

func take_damage(damage: int) -> int:
	health_bar.value -= damage
	return health_bar.value

func populate_buffs_array() -> void:
	for i in items_equipped:
		buffs[i.effect_type] = i.multiplier

func flip_sprite() -> void:
	sprite.flip_h = true
