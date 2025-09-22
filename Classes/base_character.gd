################BASE CHARACTER################
#Battle Init

extends Node

class_name Character

var sprite: AnimatedSprite2D
var health_bar: ProgressBar
var sound: AudioStreamPlayer
var attribute_icons: Dictionary
var ailment_icons: Dictionary

var char_name: String
var alliance: GameData.Alliance
var max_health: int
var max_energy: int
var current_main_energy: int
var current_reserve_energy: int

var is_player: bool = false

var action_points: int = 5
var role: Data.MachineRole

var base_attributes = {}
var current_attributes = {}
var passive = {}

var items: Array

var base_abilities: Array
var current_abilities: Array

var items_equipped: Array
var status_effects: Array
	
var grid_position: Vector2i

var guardian: Character = null
var is_aiming: bool
var mobility_changed: bool
var move_range = Vector2i(1, 1)
var has_moved: bool = false

var turn_count: int
var battle_id: int

func init(player_id: int, char_name: String, char_attributes: Dictionary, char_alliance: GameData.Alliance, energy: int, max_health: int, abilities: Array, grid_position: Vector2i, role = Data.MachineRole.NONE, items: Array = []):
	self.health_bar = self.get_node("CharHealth")
	self.sprite = self.get_node("CharSprite")
	self.sound = self.get_node("CharSound")
	build_attribute_icons()
	build_ailment_icons()
	
	self.battle_id = player_id
	self.char_name = char_name
	self.alliance = char_alliance
	
	passive = GameData.passives[char_name]
	
	if alliance == Data.Alliance.ENEMY:
		flip_sprite()
	self.max_health = max_health
	self.max_energy = energy
	self.current_main_energy = max_energy / 2
	self.current_reserve_energy = max_energy / 2
	self.role = role
	set_health()
	set_attributes(char_attributes)
	set_abilities(abilities)
	set_items(items)
	set_grid_position(grid_position)
	sprite.play()

func set_grid_position(next_position: Vector2i):
	self.grid_position = next_position
	self.z_index = (3 - grid_position.y) * 2
	
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
	self.base_abilities = char_abilities
	set_abilities_by_memory()

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
	match selected_ability.name:
		"Trample":
			if has_moved:
				damage += 25
		"Charge Beam":
			if is_aiming:
				damage += 25
		
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
		
	resolve_special_stats()
	resolve_status_effects()
	
func check_success(selected_ability: Dictionary) -> bool:
	var success: bool
	if is_aiming:
		success = true
		return success
	var type = selected_ability.ability_type
	match type:
		Data.AbilityType.ATTACK:
			var base_success = 85
			var optics = current_attributes[Data.Attributes.OPTICS]
			for optic in range(optics):
				base_success += 2
				var range = randi_range(1, 100)
				success = range < base_success
		Data.AbilityType.EFFECT:
			var base_success = 65
			var optics = current_attributes[Data.Attributes.OPTICS]
			for optic in range(optics):
				base_success += 4
				var range = randi_range(1, 100)
				success = range < base_success
	return success

func set_is_aiming(is_currently_aiming: bool) -> void:
	is_aiming = is_currently_aiming

func set_guardian(guard: Character = null) -> void:
	self.guardian = guard

func get_guardian():
	return guardian
	
func flip_sprite() -> void:
	sprite.flip_h = true
		
func use_action(cost: int) -> bool:
	var next_points = action_points - cost
	if next_points < 0:
		return false
	else:
		action_points = next_points
		return true

func use_energy(cost: int) -> bool:
	var next_points = current_main_energy - cost
	if next_points <= 0:
		current_main_energy = 0
		current_reserve_energy += next_points
		if current_reserve_energy <= 0:
			return false
		else:
			return true
	else:
		current_main_energy = next_points
		return true

func start_turn():
	turn_count = (turn_count + 1 % 6)
	if turn_count == 0:
		turn_count = 1
	has_moved = false
	resolve_status_effects()
	set_abilities_by_memory()
	update_action_points()
	update_energy()

func end_turn():
	mobility_changed = false
	is_aiming = false
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
					current_attributes[Data.Attributes.SHIELDING] -= status.value
				Data.Ailments.ACIDIZED:
					current_attributes[Data.Attributes.ARMOR] -= status.value
					mobility_changed = true
				Data.Ailments.BLANCHED:
					current_attributes[Data.Attributes.MEMORY] -= status.value
				Data.Ailments.CONCUSSED:
					current_attributes[Data.Attributes.STRENGTH] -= status.value
		#elif status.type == Data.EffectType.RESTORE:   #For removing all ailments
			#match status.property:
				#Data.SpecialStat.AILMENTS:
					#status_effects = status_effects.filter(func(status): return status.type != Data.EffectType.AILMENT)
		
	for attribute in current_attributes.keys():
		if current_attributes[attribute] < 0:
			current_attributes[attribute] = 0;
	
	resolve_status_icons()
			
func resolve_special_stats():
	for effect in status_effects:
		if effect.type == Data.EffectType.STATS:
			match effect.property:
				Data.SpecialStat.AP:
					action_points += effect.value
				Data.SpecialStat.HP:
					health_bar.value += effect.value
				Data.SpecialStat.MOVE_RANGE:
					move_range *= effect.value
			status_effects = status_effects.filter(func(e): return e != effect)
	
func decrement_status_effects():
	for status in status_effects:
		if status.type == Data.EffectType.AILMENT:
			status.value -= 1
		elif status.duration > 0:
			status.duration -= 1
	resolve_status_effects()
	
	for status in status_effects:
		if status.value == Data.permanent:
			continue
		if status.value == 0: # duration check for ailments
			status_effects.erase(status)
			ailment_icons[status.type].visible = false
			if status.type == Data.EffectType.AILMENT:
				return map_ailment_to_string(status.property)
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

func update_energy() -> void:
	if current_main_energy == max_energy / 2:
		return
	var recharge = 2 + current_attributes[Data.Attributes.BATTERY]
	current_main_energy += recharge
	
func set_abilities_by_memory() -> void:
	var memory = current_attributes[Data.Attributes.MEMORY]
	current_abilities.clear()
	for i in range(2 + memory):
		if i <= base_abilities.size() - 1:
			current_abilities.append(base_abilities[i])
	
func update_status(next_effect: Dictionary) -> void:
	var status_exists: bool = false
	for status in status_effects:
		if status.property == next_effect.property:
			status.value += next_effect.value
			status_exists = true
	if !status_exists:
		status_effects.append(next_effect)
	
func resolve_status_icons() -> void:
	for attribute in current_attributes:
		var difference = current_attributes[attribute] - base_attributes[attribute]
		var icon = attribute_icons[attribute]
		if difference == 0:
			icon.visible = false
			continue
		var number_sprite = icon.get_child(0)
		icon.visible = true
		var animation = "green" if difference > 0 else "red"
		number_sprite.animation = animation
		var frame = abs(difference) if difference < 10 else 11
		number_sprite.frame = frame
		
	for status in status_effects:
		if status.property == Data.EffectType.AILMENT:
			var icon = ailment_icons[map_ailment_to_string(status.type)]
			icon.visible = true
			var number_sprite = icon.get_child(0)
			number_sprite.animation = "red"
			number_sprite.frame = status.duration
	
func build_attribute_icons() -> void:
	var attributes = [Data.Attributes.ARMOR, Data.Attributes.BATTERY, Data.Attributes.FLUX, Data.Attributes.MEMORY, Data.Attributes.OPTICS, Data.Attributes.SHIELDING, Data.Attributes.MOBILITY, Data.Attributes.STRENGTH]
	var status_container = health_bar.get_child(0)
	if status_container == null:
		return
	var attributes_container = status_container.get_child(0)
	for attribute in attributes:
		attribute_icons[attribute] = attributes_container.get_node(map_attribute_to_string(attribute))
		
func build_ailment_icons() -> void:
	var ailments = ["Corroded", "Blanked", "Overheated"]
	var status_container = health_bar.get_child(0)
	var ailments_container = status_container.get_child(1)
	for ailment in ailments:
		ailment_icons[ailment] = ailments_container.get_node(ailment)

func map_attribute_to_string(attribute: Data.Attributes) -> String:
	match attribute:
		Data.Attributes.ARMOR:
			return "Armor"
		Data.Attributes.BATTERY:
			return "Battery"
		Data.Attributes.FLUX:
			return "Flux"
		Data.Attributes.MEMORY:
			return "Memory"
		Data.Attributes.OPTICS:
			return "Optics"
		Data.Attributes.SHIELDING:
			return "Shielding"
		Data.Attributes.MOBILITY:
			return "Mobility"
		Data.Attributes.STRENGTH:
			return "Strength"
		_:
			return ""

func map_ailment_to_string(ailment: Data.Ailments) -> String:
	match ailment:
		Data.Ailments.OVERHEATED:
			return "Overheated"
		Data.Ailments.ACIDIZED:
			return "Corroded"
		Data.Ailments.BLANCHED:
			return "Blanked"
		Data.Ailments.CONCUSSED:
			return "Concussed"
		_:
			return ""
	
