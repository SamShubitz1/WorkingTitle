extends Node

# select_by_priority() is the main thing. You pass it an array of elements with the shape {"object": Object, "priority": int} and it returns an object fron the array based off priority

# most of the other functions are for calculating priorities from an array of objects (abilities, targets, surveys) and building priority objects

# a survey has the shape {"ability": Data.Abilities, "targets": Array[Character], "should_move": bool} - we choose a target survey based off of priority - and to calculate target survey priority, we also take into account and calculate individual target priorities

# build_turn() coordinates all of this and returns a list of enemy actions for the turn

func build_turn(enemy: Character, players: Array) -> Array:
	var enemy_turn: Array
	
	#var action = get_priority_action()
	var selected_ability: Dictionary = get_priority_ability(enemy.abilities, enemy)
	var targets: Array = get_targets(players, selected_ability)
	var surveys: Array = get_surveys(enemy, targets, selected_ability)
	
	if surveys.is_empty():
		pass
		#var selected_survey = get_priority_targets(targets)
		#var next_pos = get_priority_move(players, enemy, selected_survey.targets)
		#if next_pos != enemy.grid_position:
			#enemy_turn.append({"type": Data.EnemyAction.MOVE, "position": next_pos})
			#enemy_turn.append
	else:
		var targets_with_priorities = get_targets_with_priorities(targets)
		var selected_survey = get_priority_survey(surveys, targets_with_priorities)
		if selected_survey.should_move:
			var next_pos = get_next_position(players, enemy, selected_survey.selected_cell)
			if next_pos != enemy.grid_position:
				enemy_turn.append({"type": Data.EnemyAction.MOVE, "position": next_pos})
			
		enemy_turn.append({"type": Data.EnemyAction.ABILITY, "ability": selected_survey.ability, "targets": selected_survey.targets})

	return enemy_turn

func select_by_priority(objects_with_priorities: Array):
	objects_with_priorities.sort_custom(func(objectA, objectB): return objectA.priority > objectB.priority)
	var max = objects_with_priorities[0].priority
	var selected_object: Dictionary
	var difference: int
	var result = roll_dice(5, max + 10) # should be padded?
	for object in objects_with_priorities:
		var next_difference = abs(result - object.priority)
		if !difference:
			difference = next_difference
			selected_object = object
		elif next_difference < difference:
			difference = next_difference
			selected_object = object
	
	return selected_object.object

func get_priority_ability(abilities: Array, enemy: Character) -> Dictionary:
	var abilities_with_priorities: Array
	
	for ability in abilities:
		var ability_with_priority = {"object": ability, "priority": 10}
		
		#match enemy.role:
			#Data.MachineRole.ETANK:
		if ability.damage.type == Data.DamageType.ENERGY:
			ability_with_priority.priority += 10
		if ability.target_type == Data.TargetType.ENEMY:
			ability_with_priority.priority += 7
			if enemy.turn_count > 2:
				ability_with_priority.priority += 5
		if ability.target_type == Data.TargetType.HERO:
			ability_with_priority.priority += 4
		if ability.attribute_bonus == Data.Attributes.FLUX:
			ability_with_priority.priority += 7
			
		var target_is_self = false
		for effect in ability.effects:
			if effect.target == Data.EffectTarget.SELF:
				target_is_self = true
		if target_is_self:
			ability_with_priority.priority += 5
			if enemy.turn_count < 3:
				ability_with_priority.priority += 5
			
		if !ability.effects.is_empty():
			ability_with_priority.priority += 10
			
		abilities_with_priorities.append(ability_with_priority)
		
				
	#for i in range(abilities.size()):
		#var priority = i * 10
		#for effect in abilities[i].effects:
			#priority += 10
		#
		#abilities_with_priorities.append({"object": abilities[i], "priority": priority})
	#
	#abilities.sort_custom(func(abilityA, abilityB): abilityA.damage.value > abilityB.damage.value)
	
	var selected_ability = select_by_priority(abilities_with_priorities)
	return selected_ability

func get_priority_survey(surveys, targets_with_priorities) -> Dictionary:
	var surveys_with_priorities: Array

	for survey in surveys:
		var survey_with_priority = {"object": survey, "priority": 0}
		survey_with_priority.priority += survey.targets.size() * 10
		for pt in targets_with_priorities:
			if pt.target in survey.targets:
				var max_priority
				for survey_target in survey.targets:
					if !max_priority:
						max_priority = pt.priority
					elif pt.priority > max_priority:
						max_priority = pt.priority
		
		surveys_with_priorities.append(survey_with_priority)
					
	var selected_survey = select_by_priority(surveys_with_priorities)
	return selected_survey

func get_surveys(enemy: Character, targets: Array, ability: Dictionary) -> Array:
	var max_range = ability.range + Vector2i(1, 1)
	var surveys: Array
	var origin = enemy.grid_position
	
	var valid_cells = get_valid_cells(origin, ability)
	
	for cell in valid_cells:
		var survey = {"ability": ability, "targets": [], "should_move": false, "selected_cell": Vector2i.ZERO}
		var selected_cells = Utils.get_neighbor_coords(cell, ability.shape, Data.Alliance.ENEMY)
		for target in targets: 
			if target.grid_position in selected_cells:
				survey.selected_cell = Vector2i(cell)
				if (origin.x - max_range.x) == target.grid_position.x || abs(origin.y - max_range.y) == target.grid_position.y:
					survey.should_move = true
				survey.targets.append(target)
		if !survey.targets.is_empty():
			surveys.append(survey)
#
	return surveys

func get_targets_with_priorities(targets) -> Array:
	var targets_with_priorities: Array
	targets.sort_custom(func(targetA, targetB): targetA.health_bar.value < targetB.health_bar.value)
	for i in range(targets.size()):
		var priority = i * 10
		targets_with_priorities.append({"target": targets[i], "priority": priority})
		
	return targets_with_priorities
	
func check_valid_move(origin: Vector2i, target_pos: Vector2i, range: Vector2i):
	if origin.x - range.x + 1 == target_pos.x && origin.x - 1 > 3: # hard coded
		return Vector2i(origin.x - 1, origin.y)
	elif origin.y - range.x + 1 == target_pos.x && origin.x - 1 > 3: # hard coded
		return Vector2i(origin.x - 1, origin.y)
	
func get_next_position(players, enemy, selected_cell) -> Vector2i:
	var current_x = enemy.grid_position.x
	var current_y = enemy.grid_position.y
	
	var enemy_positions: Array
	for player in players:
		if player.alliance == Data.Alliance.ENEMY:
			enemy_positions.append(player.grid_position)
	
	if selected_cell.y - current_y == 1 && Vector2i(current_x, current_y + 1) not in enemy_positions:
		current_y += 1
	elif selected_cell.y - current_y == -1 && Vector2i(current_x, current_y - 1) not in enemy_positions:
		current_y -= 1
	if selected_cell.x > current_x && Vector2i(current_x + 1, current_y) not in enemy_positions:
		current_x += 1
	elif selected_cell.x < current_x && current_x > 4 && Vector2i(current_x - 1, current_y) not in enemy_positions:
		current_x -= 1
		
	return Vector2i(current_x, current_y)
		
func get_targets(players: Array[Character], ability: Dictionary) -> Array:
	var targets: Array
	if ability.target_type == Data.TargetType.ENEMY:
		targets = players.filter(func(player): return player.alliance == Data.Alliance.HERO)
	elif ability.target_type == Data.TargetType.HERO:
		targets = players.filter(func(player): return player.alliance == Data.Alliance.ENEMY)
	return targets
	
func get_valid_cells(origin: Vector2i, ability) -> Array:
	var max_range = ability.range + Vector2i(1, 1)
	var valid_cells: Array
	
	if ability.range == Vector2i.ZERO:
		valid_cells.append(origin)
	
	var valid_x_values: Array # hard coded
	var x_range: Vector2i
	if ability.target_type == Data.TargetType.ENEMY:
		valid_x_values = [0,1,2,3]
		x_range = Vector2i(origin.x - max_range.x, origin.x)
	elif ability.target_type == Data.TargetType.HERO:
		valid_x_values = [4,5,6,7]
		x_range = Vector2i(origin.x - max_range.x, origin.x + max_range.x)
		
	var valid_y_values = [0,1,2,3]
	var y_range = Vector2i(origin.y - max_range.y, origin.y + max_range.y)
	
	for y in range(y_range.x, y_range.y):
		for x in range(x_range.x, x_range.y):
			if x in valid_x_values && y in valid_y_values:
				valid_cells.append(Vector2i(x,y))
	
	return valid_cells
		
func roll_dice(attempts: int, sides: int) -> int:
	var result = 0
	for i in range(attempts):
		var next_result = randi() % sides
		if next_result > result:
			result = next_result
	return result
