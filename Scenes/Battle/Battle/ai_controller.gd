extends Node

func build_turn(enemy: Character, players: Array) -> Array: #selects an ability based off calculated priorities, then uses it to build an enemy turn
	var enemy_turn: Array
	var current_abilities = enemy.current_abilities
	var current_ability: Dictionary
	
	for i in range(current_abilities.size()):
		current_ability = get_priority_ability(current_abilities, enemy)
		if current_ability.action_cost > enemy.action_points:
			current_abilities = enemy.current_abilities.filter(func(a): return a.name != current_ability.name)
			break
		enemy_turn = get_next_turn(enemy, players, current_ability)
		if !enemy_turn.is_empty():
			break
		else: #if a valid turn is not found, selected ability is filtered out and we try again until we run out of abilities 
			current_abilities = enemy.current_abilities.filter(func(a): return a.name != current_ability.name)
	
	if enemy_turn.is_empty(): #if valid turn is not found, we choose a target based off calculated priorities and move towards it
		var target = get_priority_target(players, current_ability)
		var next_pos = get_next_position(players, enemy, target.grid_position)
		if next_pos:
			enemy_turn.append({"type": Data.EnemyAction.MOVE, "position": next_pos})
	
	var should_aim = check_should_aim(enemy_turn, enemy.action_points)
	print(enemy.char_name , "Is aiming " , should_aim)
	if should_aim:
		enemy_turn.push_front({"type": Data.EnemyAction.AIM })
	
	return enemy_turn

func get_next_turn(enemy, players, ability) -> Array: # builds an enemy turn based off selected ability - an enemy_turn is a list of objects with a property "type": Data.EnemyAction (can be MOVE, ABILITY, GUARD, etc.) and other needed info like "position" or "ability"
	var next_turn: Array

	var targets: Array = get_targets(players, ability)
	var surveys: Array = get_surveys(enemy, targets, ability)
	
	if surveys.is_empty():
		return []
	
	var targets_with_priorities = get_targets_with_priorities(targets)
	var selected_survey = get_priority_survey(surveys, targets_with_priorities)
	
	var can_move = enemy.action_points - selected_survey.ability.action_cost >= 0
	
	if selected_survey.should_move && !can_move:
		return []
	elif selected_survey.should_move:
		var next_pos = get_next_position(players, enemy, selected_survey.selected_cell)
		if next_pos:
			next_turn.append({"type": Data.EnemyAction.MOVE, "position": next_pos})
			if target_in_range(next_pos, selected_survey.selected_cell, ability.range):
				next_turn.append({"type": Data.EnemyAction.ABILITY, "ability": selected_survey.ability, "targets": selected_survey.targets})
	else:
		next_turn.append({"type": Data.EnemyAction.ABILITY, "ability": selected_survey.ability, "targets": selected_survey.targets})
			
	return next_turn
	
func select_by_priority(objects_with_priorities: Array): #takes an array of objects with the shape {"object": object, "priority": int} - object can be an ability, target, or survey (will probably add more) - and rolls dice to return a selected object
	objects_with_priorities.sort_custom(func(objectA, objectB): return objectA.priority > objectB.priority)
	var max = objects_with_priorities[0].priority
	var selected_object: Dictionary
	var difference = null
	var result = roll_dice(2, max + int(max * .25)) # should be padded?
	for object in objects_with_priorities:
		var next_difference = abs(result - object.priority)
		if difference == null:
			difference = next_difference
			selected_object = object
		elif next_difference < difference:
			difference = next_difference
			selected_object = object
	if selected_object.has("targets"):
		return selected_object.object
	
	return selected_object.object

func get_priority_ability(abilities: Array, enemy: Character) -> Dictionary: #select an ability based off calculated priorities
	var abilities_with_priorities: Array
	
	for ability in abilities: #builds priority objects {"object": object, "priority": int}
		var ability_with_priority = {"object": ability, "priority": 10}
		var ability_tags = get_ability_tags(ability)
		
		var effect_turns: Array
		var attack_turns: Array
		
		var effect_weight = 10
		var attack_weight = 10
		var offensive_weight = 0
		var defensive_weight = 0
		var energy_weight = 0
		var physical_weight = 0
		var target_self_weight = 0
		var flux_bonus_weight = 0
		var strength_bonus_weight = 0
		var has_effect_weight = 0
		var damage_divider = 0

		match enemy.role:
			Data.MachineRole.ETANK:
				effect_turns = [1,2]
				attack_turns = [3,4,5]
				
				defensive_weight = 10
				target_self_weight = 10
				
				energy_weight = 10
				flux_bonus_weight = 10
				has_effect_weight = 5
				
				damage_divider = 15
						
			Data.MachineRole.PTANK:
				effect_turns = [1,2]
				attack_turns = [3,4,5]
				
				defensive_weight = 10
				target_self_weight = 10
				
				physical_weight = 10
				strength_bonus_weight = 10
				has_effect_weight = 5
				
				damage_divider = 15
						
			Data.MachineRole.EASSAULTER:
				effect_turns = [1,5]
				attack_turns = [2,3,4]
				
				offensive_weight = 10
				
				energy_weight = 10
				flux_bonus_weight = 10
				has_effect_weight = 5
				
				damage_divider = 8
					
			Data.MachineRole.PASSAULTER:
				effect_turns = [1,5]
				attack_turns = [2,3,4]
				
				offensive_weight = 10
				
				physical_weight = 10
				strength_bonus_weight = 10
				has_effect_weight = 5
				
				damage_divider = 8
			
			Data.MachineRole.ESNIPER:
				effect_turns = [5]
				attack_turns = [1,2,3,4]
				
				offensive_weight = 10
				
				energy_weight = 10
				flux_bonus_weight = 10
				has_effect_weight = 5
				
				damage_divider = 5
	
			Data.MachineRole.PSNIPER:
				effect_turns = [5]
				attack_turns = [1,2,3,4]
				
				offensive_weight = 10
				
				physical_weight = 10
				strength_bonus_weight = 10
				has_effect_weight = 5
				
				damage_divider = 5
						
			Data.MachineRole.EOSUPPORT:
				effect_turns = [1,2,5]
				attack_turns = [3,4]
				
				offensive_weight = 10
				
				energy_weight = 10
				flux_bonus_weight = 10
				has_effect_weight = 5
				
				damage_divider = 20
				
			Data.MachineRole.POSUPPORT:
				effect_turns = [1,2,5]
				attack_turns = [3,4]
				
				offensive_weight = 10
				
				physical_weight = 10
				strength_bonus_weight = 10
				has_effect_weight = 5
				
				damage_divider = 20
			
			Data.MachineRole.EDSUPPORT:
				effect_turns = [1,2,4,5]
				attack_turns = [3]
				
				defensive_weight = 10
				
				energy_weight = 10
				flux_bonus_weight = 10
				has_effect_weight = 5
				
				damage_divider = 20
			
			Data.MachineRole.PDSUPPORT:
				effect_turns = [1,2,4,5]
				attack_turns = [3]
				
				defensive_weight = 10
				
				physical_weight = 10
				strength_bonus_weight = 10
				has_effect_weight = 5
				
				damage_divider = 20
		
		if enemy.turn_count in effect_turns:
			if "effect" in ability_tags:
				ability_with_priority.priority += effect_weight
			if "offensive" in ability_tags:
				ability_with_priority.priority += offensive_weight
			if "defensive" in ability_tags:
				ability_with_priority.priority += defensive_weight
			if "target_self" in ability_tags:
				ability_with_priority.priority += target_self_weight
					
		elif enemy.turn_count in attack_turns:
			if "attack" in ability_tags:
				ability_with_priority.priority += attack_weight
			if "energy" in ability_tags:
				ability_with_priority.priority += energy_weight
			if "physical" in ability_tags:
				ability_with_priority.priority += physical_weight
			if "flux_bonus" in ability_tags:
				ability_with_priority.priority += flux_bonus_weight
			if "strength_bonus" in ability_tags:
				ability_with_priority.priority += strength_bonus_weight
			if "has_effect" in ability_tags:
				ability_with_priority.priority += has_effect_weight
						
			var damage_bonus = int(ability.damage.value/damage_divider)
			ability_with_priority.priority += damage_bonus
			
		ability_with_priority.priority += randi_range(-2, 2)
			
		abilities_with_priorities.append(ability_with_priority)
		
	var selected_ability = select_by_priority(abilities_with_priorities)
	return selected_ability

func get_priority_target(players, ability): #returns selected target based off of priority
	var targets = get_targets(players, ability)
	var targets_with_priorities = get_targets_with_priorities(targets)
	var selected_target = select_by_priority(targets_with_priorities)
	if selected_target:
		return selected_target

func get_priority_survey(surveys, targets_with_priorities) -> Dictionary: #selects a survey based off calculated priorities - also takes into account individual target priorities
	var surveys_with_priorities: Array

	for survey in surveys: 
		var survey_with_priority = {"object": survey, "priority": 0}
		survey_with_priority.priority += survey.targets.size() * 10
		
		for twp in targets_with_priorities: #we find the target in the survey with the highest priority and add it to the survey's own priority
			if twp.object in survey.targets:
				var max_priority
				for survey_target in survey.targets:
					if !max_priority:
						max_priority = twp.priority
					elif twp.priority > max_priority:
						max_priority = twp.priority

				survey_with_priority.priority += max_priority
		
		surveys_with_priorities.append(survey_with_priority)
					
	var selected_survey = select_by_priority(surveys_with_priorities)
	return selected_survey

func get_targets_with_priorities(targets) -> Array: #returns a list of targets with priorities
	var targets_with_priorities: Array
	targets.sort_custom(func(targetA, targetB): targetA.health_bar.value < targetB.health_bar.value) # placeholder logic
	for i in range(targets.size()):
		var priority = i + 1 * 10
		targets_with_priorities.append({"object": targets[i], "priority": priority})
		
	return targets_with_priorities

func get_surveys(enemy: Character, targets: Array, ability: Dictionary) -> Array: #surveys represent a particular spot on the grid selected by a particular ability and the targets in range at that spot, including targets that could be selected after one movement
	var max_range = ability.range + Vector2i(1, 1)
	var surveys: Array
	var origin = enemy.grid_position
	
	var valid_cells = get_valid_cells(origin, ability, targets)
	
	for cell in valid_cells:
		var survey = {"ability": ability, "targets": [], "should_move": false, "selected_cell": Vector2i.ZERO}
		var selected_cells = Utils.get_neighbor_coords(cell, ability.shape, Data.Alliance.ENEMY)
		for target in targets:
			if target.grid_position in selected_cells:
				survey.selected_cell = Vector2i(cell)
				survey.should_move = should_move(origin, target.grid_position, max_range) && ability.shape != Data.AbilityShape.ALL
				survey.targets.append(target)
		if !survey.targets.is_empty():
			surveys.append(survey)

	return surveys

func get_targets(players: Array[Character], ability: Dictionary) -> Array: #determines which players are valid targets
	var targets: Array
	if ability.target_type == Data.TargetType.ENEMY:
		targets = players.filter(func(player): return player.alliance == Data.Alliance.HERO)
	elif ability.target_type == Data.TargetType.HERO:
		targets = players.filter(func(player): return player.alliance == Data.Alliance.ENEMY)
	return targets
	
func get_next_position(players, enemy, selected_cell): #gets next position when movement is needed to select target
	var current_x = enemy.grid_position.x
	var current_y = enemy.grid_position.y
	
	var enemy_positions: Array
	for player in players:
		if player.alliance == Data.Alliance.ENEMY:
			enemy_positions.append(player.grid_position)
	
	var next_pos = calculate_next_pos(selected_cell, enemy.grid_position, enemy_positions)
	
	if move_is_valid(next_pos):
		return next_pos

func check_should_aim(enemy_turn: Array, action_points: int) -> bool:
	for action in enemy_turn:
		if action.type == Data.EnemyAction.ABILITY:
			if action.ability.damage.type == Data.DamageType.NONE:
				return false
	
	var turn_cost = get_turn_cost(enemy_turn)
	
	var difference = action_points - turn_cost
	if difference == 0:
		return false
	elif difference == 1:
		var result = roll_dice(1, 10)
		if result > 7:
			return true
	elif difference > 1:
		var result = roll_dice(1, 10)
		if result > 5:
			return true

	return false

func get_ability_tags(ability: Dictionary) -> Array:
	var tags: Array
	
	var is_offensive = ability.target_type == Data.TargetType.ENEMY
	var is_defensive = ability.target_type == Data.TargetType.HERO
	var target_self = has_target_self(ability.effects)
	
	if ability.ability_type == Data.AbilityType.EFFECT:
		tags.append("effect")
		
		if is_offensive:
			tags.append("offensive")
		elif is_defensive:
			tags.append("defensive")
		if target_self:
			tags.append("target_self")
	elif ability.ability_type == Data.AbilityType.ATTACK:
		tags.append("attack")
		
		if ability.damage.type == Data.DamageType.PHYSICAL:
			tags.append("physical")
		elif ability.damage.type == Data.DamageType.ENERGY:
			tags.append("energy")
		if ability.attribute_bonus == Data.Attributes.STRENGTH:
			tags.append("strength_bonus")
		if ability.attribute_bonus == Data.Attributes.FLUX:
			tags.append("flux_bonus")
		if !ability.effects.is_empty():
			tags.append("has_effect")
	
	return tags
	
func has_target_self(effects: Array) -> bool:
	var target_self = false
	for effect in effects:
		if effect.target == Data.EffectTarget.SELF:
			target_self = true
	return target_self
	
func get_valid_cells(origin: Vector2i, ability: Dictionary, targets: Array) -> Array: #returns every cell the enemy could select if they moved once
	var max_range = ability.range + Vector2i(1, 1)
	var valid_cells: Array
	
	if ability.range == Vector2i.ZERO && ability.target_type == Data.TargetType.HERO:
		return [origin]
		
	match ability.shape:
		Data.AbilityShape.LINE:
			valid_cells.append_array([Vector2i(7, origin.y),Vector2i(7, origin.y),Vector2i(7, origin.y - 1)]) #hard coded
			return valid_cells
		Data.AbilityShape.MELEE:
			valid_cells = get_melee_targets(targets)
			return valid_cells
		Data.AbilityShape.ALL:
			return [origin]
				
	var valid_x_values: Array 
	var x_range: Vector2i
	if ability.target_type == Data.TargetType.ENEMY:
		valid_x_values = [0,1,2,3] # currently hard coded
		x_range = Vector2i(origin.x - max_range.x, origin.x + max_range.x)
	elif ability.target_type == Data.TargetType.HERO:
		valid_x_values = [4,5,6,7]
		x_range = Vector2i(origin.x - max_range.x, origin.x + max_range.x)
		
	var valid_y_values = [0,1,2,3]
	var y_range = Vector2i(origin.y - max_range.y, origin.y + max_range.y)
	
	for y in range(y_range.x, y_range.y + 1):
		for x in range(x_range.x, x_range.y + 1):
			if x in valid_x_values && y in valid_y_values:
				var next_cell = Vector2i(x,y)
				if next_cell not in valid_cells:
					valid_cells.append(next_cell)
	
	return valid_cells
	
func get_melee_targets(targets: Array) -> Array:
	var melee_target_cells: Dictionary
	for target in targets:
		if target.grid_position.y in melee_target_cells.keys():
			var neighbor_cell = melee_target_cells[target.grid_position.y]
			if neighbor_cell.x > target.grid_position.x:
				break
			else:
				melee_target_cells[target.grid_position.y] = target.grid_position
		else:
			melee_target_cells[target.grid_position.y] = target.grid_position
			
	return melee_target_cells.values()

func move_is_valid(next_pos): #ensures the enemy doesn't move too far left, tracking/moving logic already disallows enemy from moving too far in other directions
	if !next_pos:
		return false
	elif next_pos.x > 3:
		return true
	
func should_move(origin: Vector2i, target_pos: Vector2i, max_range: Vector2i) -> bool: #used to determine if the enemy needs to move one space before target is in range
	if (abs(origin.x - target_pos.x) == max_range.x || abs(origin.y - target_pos.y) == max_range.y):
		return true
	return false
	
func target_in_range(origin: Vector2i, target_cell: Vector2i, range: Vector2i) -> bool: #used to determine if target is in range
	if abs(origin.x - target_cell.x) <= range.x && abs(origin.y - target_cell.y) <= range.y || range == Vector2i.ZERO:
		return true
	return false
		
func roll_dice(attempts: int, sides: int) -> int:
	var result = 0
	for i in range(attempts):
		var next_result = randi() % sides
		if next_result > result:
			result = next_result
	return result
	
func get_turn_cost(turn: Array) -> int:
	var cost: int
	for action in turn:
		match action.type:
			Data.EnemyAction.MOVE:
				cost += 1
			Data.EnemyAction.ABILITY:
				cost += action.ability.action_cost
	print("Cost before aim ", cost)
	return cost

func calculate_next_pos(selected_cell: Vector2i, current_pos: Vector2i, occupied_cells: Array): #prioritizes moving diagonal if needed, then up or down, then left or right
	var up = Vector2i(current_pos.x, current_pos.y + 1)
	var down = Vector2i(current_pos.x, current_pos.y - 1)
	var left = Vector2i(current_pos.x - 1, current_pos.y)
	var right = Vector2i(current_pos.x + 1, current_pos.y)
	var up_left = Vector2i(current_pos.x - 1, current_pos.y + 1)
	var up_right = Vector2i(current_pos.x + 1, current_pos.y + 1)
	var down_left = Vector2i(current_pos.x - 1, current_pos.y - 1)
	var down_right = Vector2i(current_pos.x + 1, current_pos.y - 1)

	if selected_cell.x < current_pos.x:
		if selected_cell.y < current_pos.y:
			if down_left not in occupied_cells:
				return down_left
			elif down not in occupied_cells:
				return down
			elif left not in occupied_cells:
				return left
		elif selected_cell.y > current_pos.y:
			if up_left not in occupied_cells:
				return up_left
			elif up not in occupied_cells:
				return up
			elif left not in occupied_cells:
				return left
		elif selected_cell.y == current_pos.y:
			if left not in occupied_cells:
				return left
	elif selected_cell.x > current_pos.x:
		if selected_cell.y < current_pos.y:
			if down_right not in occupied_cells:
				return down_right
			elif down not in occupied_cells:
				return down
			elif right not in occupied_cells:
				return right
		elif selected_cell.y > current_pos.y:
			if up_right not in occupied_cells:
				return up_right
			elif up not in occupied_cells:
				return up
			elif right not in occupied_cells:
				return right
		elif selected_cell.y == current_pos.y:
			if right not in occupied_cells:
				return right
