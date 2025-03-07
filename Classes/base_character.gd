extends Node

class_name Character

var char_name: String
var alliance: GameData.Alliance
var max_health: int
var is_player: bool = false
var health_bar: ProgressBar
var sprite: AnimatedSprite2D

var attributes = {GameData.Attributes.STRENGTH: 1, GameData.Attributes.FLUX: 1, GameData.Attributes.ARMOR: 1, GameData.Attributes.SHIELDING: 1, GameData.Attributes.MEMORY: 1, GameData.Attributes.BATTERY: 1, GameData.Attributes.OPTICS: 1, GameData.Attributes.MOBILITY: 1}

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

func take_damage(damage_event: Dictionary) -> Dictionary:
	var damage_type = damage_event.damage_type
	var damage_result: int
	match damage_type:
		GameData.DamageType.PHYSICAL:
			var armor: float = attributes[GameData.Attributes.ARMOR]
			var multiplier: float = 1 - (armor / 10)
			damage_result = damage_event.damage * multiplier
		GameData.DamageType.ENERGY:
			var shielding: float = attributes[GameData.Attributes.SHIELDING]
			var multiplier: float = 1 - (shielding / 10)
			
	health_bar.value -= damage_result
	var event_dialog = resolve_effects(damage_event.effect)
	return {"damage": damage_result, "dialog": event_dialog}

func populate_buffs_array() -> void:
	for i in items_equipped:
		buffs[i.effect_type] = i.multiplier

func resolve_effects(effect: Dictionary):
	if !effect.is_empty():
		var property = effect.affected_property
		var value = effect.effect_value
		var dialog = effect.effect_dialog
		attributes[property] += value
		if dialog:
			return dialog


func flip_sprite() -> void:
	sprite.flip_h = true
