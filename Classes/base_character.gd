extends Node

class_name Character

var char_name: String
var alliance: GameData.Alliance
var max_health: int
var is_player: bool = false
var health_bar: ProgressBar
var sprite: AnimatedSprite2D
var action_points: int = 5
var role: Data.MachineRole

var base_attributes = {}

var current_attributes = {}

var items: Array
var abilities: Array
var items_equipped: Array
var status_effects: Array
#var buffs: Dictionary
	
var grid_position: Vector2i

var guardian: Character = null
var mobility_changed: bool
var movement_range = Vector2i(1, 1)
var turn_count: int

func init(char_name: String, char_attributes: Dictionary, char_alliance: GameData.Alliance, char_sprite: AnimatedSprite2D, char_health: ProgressBar, max_health: int, abilities: Array, grid_position: Vector2i, role = Data.MachineRole.NONE, items: Array = []):
	self.char_name = char_name
	self.alliance = char_alliance
	self.sprite = char_sprite
	self.health_bar = char_health
	self.max_health = max_health
	self.role = role
	set_health()
	set_attributes(char_attributes)
	set_abilities(abilities)
	set_items(items)
	set_grid_position(grid_position)
	sprite.play()

func set_grid_position(next_position: Vector2i):
	self.grid_position = next_position
	self.z_index = 3 - grid_position.y
	
func set_health() -> void:
	health_bar.max_value = max_health
	health_bar.value = max_health
	health_bar.z_index = -1

func set_attributes(char_attributes):
	self.base_attributes = char_attributes
	current_attributes = base_attributes.duplicate(true)
	
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
			var armor: float = current_attributes[GameData.Attributes.ARMOR]
			var multiplier: float = 1 - (armor / 10)
			damage_result = damage_event.damage * multiplier
		GameData.DamageType.ENERGY:
			var shielding: float = current_attributes[GameData.Attributes.SHIELDING]
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
		var value: float = current_attributes[attribute]
		var multiplier: float = 1 + (value / 10)
		return multiplier

func resolve_effect(effect: Dictionary):
	if effect.has("duration"):
		update_status({"type": effect.effect_type, "property": effect.property, "value": effect.value, "duration": effect.duration})
	else:
		update_status({"type": effect.effect_type, "property": effect.property, "value": effect.value})
		
	resolve_status_effects()
	
func check_success(selected_ability: Dictionary) -> bool:
	var success: bool
	var type = selected_ability.ability_type
	match type:
		Data.AbilityType.ATTACK:
			var base_success = 90
			var optics = current_attributes[Data.Attributes.OPTICS]
			for optic in range(optics):
				base_success += 2
				var range = randi_range(1, 100)
				success = range < base_success
		Data.AbilityType.EFFECT:
			var base_success = 75
			var optics = current_attributes[Data.Attributes.OPTICS]
			for optic in range(optics):
				base_success += 4
				var range = randi_range(1, 100)
				success = range < base_success

	return success

func set_guardian(guard: Character = null) -> void:
	self.guardian = guard

func get_guardian():
	return guardian
	
func flip_sprite() -> void:
	sprite.flip_h = true
	
#func populate_buffs_array() -> void:
	#for i in items_equipped:
		#buffs[i.effect_type] = i.multiplier
		
func use_action(cost: int) -> bool:
	var next_points = action_points - cost
	if next_points < 0:
		return false
	else:
		action_points = next_points
		return true

func start_turn():
	turn_count = (turn_count + 1 % 5)
	if turn_count == 0:
		turn_count = 1
		
	update_action_points()
	resolve_status_effects()

func end_turn():
	mobility_changed = false
	var result = decrement_status_effects()
	if result:
		return result
	
func resolve_status_effects() -> void:
	current_attributes = base_attributes.duplicate(true)
	
	for status in status_effects:
		if status.type == Data.EffectType.ATTRIBUTE:
				current_attributes[status.property] += status.value
		elif status.type == Data.EffectType.AILMENT:
			match status.property:
				Data.Ailments.OVERHEATED:
					current_attributes[Data.Attributes.BATTERY] -= status.value
					current_attributes[Data.Attributes.SHIELDING] -= status.value
				Data.Ailments.ACIDIZED:
					current_attributes[Data.Attributes.ARMOR] -= status.value
					current_attributes[Data.Attributes.MOBILITY] -= status.value
					mobility_changed = true
				Data.Ailments.BLANCHED:
					current_attributes[Data.Attributes.MEMORY] -= status.value
					current_attributes[Data.Attributes.OPTICS] -= status.value
				Data.Ailments.CONCUSSED:
					current_attributes[Data.Attributes.STRENGTH] -= status.value
					current_attributes[Data.Attributes.FLUX] -= status.value
		elif status.type == Data.EffectType.RESTORE:
			match status.property:
				Data.SpecialStat.AP:
					action_points += status.value
					if action_points > 5:
						action_points = 5
				Data.SpecialStat.AILMENTS:
					status_effects = status_effects.filter(func(status): return status.type != Data.EffectType.AILMENT)
					
	for attribute in current_attributes.keys():
		if current_attributes[attribute] < 0:
			current_attributes[attribute] = 0;
			
func decrement_status_effects():
	for status in status_effects:
		if status.type == Data.EffectType.AILMENT:
			status.value -= 1
		elif status.has("duration"):
			status.duration -= 1
	resolve_status_effects()
	
	for status in status_effects:
		if status.value == 0: # duration check for ailments
			status_effects.erase(status)
			var effect_name: String
			if status.type == Data.EffectType.AILMENT:
				match status.property:
					Data.Ailments.OVERHEATED:
						effect_name = "Overheated"
					Data.Ailments.ACIDIZED:
						effect_name = "Acidized"
					Data.Ailments.BLANCHED:
						effect_name = "Blanched"
					Data.Ailments.CONCUSSED:
						effect_name = "Concussed"
				return effect_name
		elif status.has("duration"):
			if status.duration == 0: # duration check for status effects
				status_effects.erase(status)
				
func update_action_points() -> void:
	if action_points < 5:
		var next_points = action_points + 3
		if next_points > 5:
			action_points = 5
		else: 
			action_points = next_points

func update_status(next_effect: Dictionary) -> void:
	var status_exists: bool = false
	for status in status_effects:
		if status.property == next_effect.property:
			status.value += next_effect.value
			status_exists = true
	if !status_exists:
		status_effects.append(next_effect)
				
func print_stats():
	if alliance == Data.Alliance.HERO:
		for attribute in current_attributes:
			match attribute:
				Data.Attributes.STRENGTH:
					print("Strength: ", current_attributes[attribute])
				Data.Attributes.ARMOR:
					print("Armor: ", current_attributes[attribute])
				Data.Attributes.SHIELDING:
					print("Shielding: ", current_attributes[attribute])
				Data.Attributes.FLUX:
					print("Flux: ", current_attributes[attribute])
				Data.Attributes.MOBILITY:
					print("Mobility: ", current_attributes[attribute])
				Data.Attributes.OPTICS:
					print("Optics: ", current_attributes[attribute])
				Data.Attributes.MEMORY:
					print("Memory: ", current_attributes[attribute])
				Data.Attributes.BATTERY:
					print("Battery: ", current_attributes[attribute])
					
		print(char_name, " current status effects: ")
		for status in status_effects:
			match status.type:
				Data.EffectType.AILMENT:
					print("Ailment:")
					match status.property:
						Data.Ailments.ACIDIZED:
							print("acidized for ", status.value)
						Data.Ailments.BLANCHED:
							print("blanched for ", status.value)
						Data.Ailments.OVERHEATED:
							print("overheated for ", status.value)
						Data.Ailments.CONCUSSED:
							print("concussed for ", status.value)
				Data.EffectType.ATTRIBUTE:
					match status.property:
						Data.Attributes.ARMOR:
							print("armor for ", status.value)
						Data.Attributes.SHIELDING:
							print("shielding ", status.value)
						Data.Attributes.STRENGTH:
							print("strength for ", status.value)
						Data.Attributes.FLUX:
							print("flux for ", status.value)
						Data.Attributes.OPTICS:
							print("optics for ", status.value)
						Data.Attributes.MEMORY:
							print("memory for ", status.value)
						Data.Attributes.MOBILITY:
							print("mobility for ", status.value)
						Data.Attributes.BATTERY:
							print("battery for ", status.value)
				Data.EffectType.RESTORE:
					match status.property:
						Data.SpecialStat.AP:
							print("AP for ", status.value)
						Data.SpecialStat.ENERGY:
							print("Energy for ", status.value)
						Data.SpecialStat.AILMENTS:
							print("All ailments for ", status.value)
