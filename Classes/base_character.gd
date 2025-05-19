extends Node

class_name Character

var char_name: String
var alliance: GameData.Alliance
var max_health: int
var max_energy: int
var current_main_energy: int
var current_reserve_energy: int


var is_player: bool = false
var health_bar: ProgressBar

var sprite: AnimatedSprite2D
var sound: AudioStreamPlayer

var action_points: int = 5
var role: Data.MachineRole

var base_attributes = {}
var current_attributes = {}

var items: Array

var base_abilities: Array
var current_abilities: Array

var items_equipped: Array
var status_effects: Array
	
var grid_position: Vector2i

var guardian: Character = null
var is_aiming: bool
var mobility_changed: bool
var movement_range = Vector2i(1, 1)
var has_moved: bool = false

var turn_count: int
var battle_id: int

func init(player_id: int, char_name: String, char_attributes: Dictionary, char_alliance: GameData.Alliance, char_sprite: AnimatedSprite2D, char_sound: AudioStreamPlayer, char_health: ProgressBar, energy: int, max_health: int, abilities: Array, grid_position: Vector2i, role = Data.MachineRole.NONE, items: Array = []):
	self.battle_id = player_id
	self.char_name = char_name
	self.alliance = char_alliance
	self.sprite = char_sprite
	self.sound = char_sound
	
	if alliance == Data.Alliance.ENEMY:
		flip_sprite()
	self.health_bar = char_health
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
				damage += 20
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
	if is_aiming:
		success = true
		return success
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
	print("Max Energy = ", max_energy, " Current Main Energy = ", current_main_energy, " Current Reserve Energy = ", current_reserve_energy)
	var next_points = current_main_energy - cost
	if next_points <= 0:
		current_main_energy = 0
		current_reserve_energy += next_points
		if current_reserve_energy <= 0:
			print("Max Energy = ", max_energy, " Current Main Energy = ", current_main_energy, " Current Reserve Energy = ", current_reserve_energy)
			return false
		else:
			print("Max Energy = ", max_energy, " Current Main Energy = ", current_main_energy, " Current Reserve Energy = ", current_reserve_energy)
			return true
	else:
		current_main_energy = next_points
		print("Max Energy = ", max_energy, " Current Main Energy = ", current_main_energy, " Current Reserve Energy = ", current_reserve_energy)
		return true

func start_turn():
	turn_count = (turn_count + 1 % 6) #move into enemy class?
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
		elif status.duration > 0:
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

enum Status {
	ATTRIBUTE
}
