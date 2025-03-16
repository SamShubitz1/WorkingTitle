extends Node

class_name Character

var char_name: String
var alliance: GameData.Alliance
var max_health: int
var is_player: bool = false
var health_bar: ProgressBar
var sprite: AnimatedSprite2D
var action_points: int = 5

var attributes = {Data.Attributes.STRENGTH: 1, Data.Attributes.FLUX: 1, Data.Attributes.ARMOR: 1, Data.Attributes.SHIELDING: 1, Data.Attributes.MEMORY: 1, Data.Attributes.BATTERY: 1, Data.Attributes.OPTICS: 1, Data.Attributes.MOBILITY: 1}

var items: Array
var abilities: Array
var items_equipped: Array
var status_effects: Array
var buffs: Dictionary
	
var grid_position: Vector2i

var guardian: Character = null

func init(char_name: String, char_alliance: GameData.Alliance, char_sprite: AnimatedSprite2D, char_health: ProgressBar, max_health: int, abilities: Array, grid_position: Vector2i, items: Array = []):
	self.char_name = char_name
	self.alliance = char_alliance
	self.sprite = char_sprite
	self.health_bar = char_health
	self.max_health = max_health
	health_bar.z_index = -1
	set_health()
	set_abilities(abilities)
	set_items(items)
	set_grid_position(grid_position)
	sprite.play()
	
	if alliance == Data.Alliance.HERO:
		health_bar.hide()

func set_grid_position(next_position: Vector2i):
	self.grid_position = next_position
	self.z_index = 3 - grid_position.y
	
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

func take_damage(damage_event: Dictionary) -> int:
	var damage_type = damage_event.type
	var damage_result: int
	match damage_type:
		GameData.DamageType.NONE:
			return false
		GameData.DamageType.PHYSICAL:
			var armor: float = attributes[GameData.Attributes.ARMOR]
			var multiplier: float = 1 - (armor / 10)
			damage_result = damage_event.damage * multiplier
		GameData.DamageType.ENERGY:
			var shielding: float = attributes[GameData.Attributes.SHIELDING]
			var multiplier: float = 1 - (shielding / 10)
			damage_result = damage_event.damage * multiplier
	if damage_result > 0:
		health_bar.value -= damage_result
	
	return damage_result

func calculate_attack_dmg(selected_ability: Dictionary):
	var damage: int = selected_ability.damage.value
	var damage_with_range = int(damage * randf_range(.9, 1.1))
	var attribute_multiplier = resolve_attribute_bonuses(selected_ability)
	if attribute_multiplier:
		damage_with_range *= float(attribute_multiplier)
	return {"damage": int(damage_with_range), "type": selected_ability.damage.type}
	
func resolve_attribute_bonuses(selected_ability: Dictionary):
	var attribute = selected_ability.attribute_bonus
	if attribute != GameData.Attributes.NONE:
		var value: float = attributes[attribute]
		var multiplier: float = 1 + (value / 10)
		return multiplier

func resolve_effect(effect: Dictionary):
	var property = effect.affected_property
	var value = effect.effect_value
	match property:
		Data.EffectType.ATTRIBUTE:
			attributes[property] += value
			
func check_success(selected_ability: Dictionary) -> bool:
	var success: bool
	var type = selected_ability.ability_type
	match type:
		Data.AbilityType.ATTACK:
			var base_success = 0
			var optics = attributes[Data.Attributes.OPTICS]
			for optic in range(optics):
				base_success += 2
				success = randi_range(1, 100) < base_success
				
		Data.AbilityType.EFFECT:
			var base_success = 0
			var optics = attributes[Data.Attributes.OPTICS]
			for optic in range(optics):
				base_success += 4
				success = randi_range(1, 100) < base_success
	
	return success

func set_guardian(guard: Character = null) -> void:
	self.guardian = guard

func get_guardian():
	return guardian
	
func flip_sprite() -> void:
	sprite.flip_h = true
	
func populate_buffs_array() -> void:
	for i in items_equipped:
		buffs[i.effect_type] = i.multiplier
		
func use_action(cost: int) -> bool:
	var next_points = action_points - cost
	if next_points < 0:
		return false
	else:
		action_points = next_points
		return true

func start_turn() -> void:
	decrement_status_effects()
	update_action_points()
			
func decrement_status_effects() -> void:
	for status in status_effects:
			status.value -= 1
	for status in status_effects: # apparently erasing items while iterating through an array is not supported
		if status.value == 0:
			status_effects.erase(status)
			
func update_action_points() -> void:
	if action_points < 5:
		var next_points = action_points + 3
		if next_points > 5:
			action_points = 5
		else: 
			action_points = next_points

func update_status(next_effect: Dictionary) -> void:
	if status_effects.is_empty():
		status_effects.append(next_effect)
	else:
		for status in status_effects:
			if status.type == next_effect.type:
				status.value += next_effect.value
			elif status.type == next_effect.type:
				pass
