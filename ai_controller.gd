extends Node

# select_by_priority() is the main player here. You pass it an array of elements with the shape {"object": Object, "priority": int} and it returns an object fron the list based off priority

# most of the other functions are for calculating priorities from a list of objects and building priority objects

# a target_survey has the shape {"ability": Data.Abilities, "targets": Array[Character]} - we choose a target survey based off of priority - and to calculate target survey priority, we also take into account individual target priorities

# build_turn() coordinates all of this and returns a list of enemy actions for the turn

func build_turn(enemy: Character, players: Array) -> Array:
	var enemy_turn: Array
	#var action = get_priority_action()
	var selected_ability: Dictionary = get_priority_ability(enemy.abilities)
	var targets = get_targets(players, selected_ability)
	var targets_with_priorities = get_targets_with_priorities(targets)
	var target_surveys = get_target_surveys(enemy, targets_with_priorities, selected_ability)
	
	if target_surveys.is_empty():
		pass
		#var selected_ability_scan = get_priority_targets(targets)
		#var next_pos = get_priority_move(players, enemy, selected_ability_scan.targets)
		#if next_pos != enemy.grid_position:
			#enemy_turn.append({"type": Data.EnemyAction.MOVE, "position": next_pos})
			#enemy_turn.append
	else:
		var selected_target_survey = get_priority_survey(target_surveys, targets_with_priorities)
		enemy_turn.append({"type": Data.EnemyAction.ABILITY, "ability": selected_target_survey.ability, "targets": selected_target_survey.targets})
			
	return enemy_turn

func select_by_priority(objects_with_priorities: Array):
	objects_with_priorities.sort_custom(func(objectA, objectB): return objectA.priority > objectB.priority)
	var max = objects_with_priorities[0].priority
	var selected_object: Dictionary
	var difference: int
	for object in objects_with_priorities:
		var result = roll_dice(2, max + 10) # should be padded?
		var next_difference = abs(result - object.priority)
		if !difference:
			difference = next_difference
			selected_object = object
		elif next_difference < difference:
			difference = next_difference
			selected_object = object
	
	return selected_object.object

func get_priority_ability(abilities: Array) -> Dictionary:
	abilities.sort_custom(func(abilityA, abilityB): abilityA.damage.value > abilityB.damage.value)
	var abilities_with_priorities: Array
	for i in range(abilities.size()):
		var priority = i * 10
		for effect in abilities[i].effects:
			priority += 10
		
		abilities_with_priorities.append({"object": abilities[i], "priority": priority})
	
	var selected_ability = select_by_priority(abilities_with_priorities)
	return selected_ability

func get_priority_survey(target_surveys, targets_with_priorities) -> Dictionary:
	var surveys_with_priorities: Array

	for survey in target_surveys:
		var survey_with_priority = {"object": survey, "priority": 0}
		survey_with_priority.priority += survey.targets.size() * 5
		for pt in targets_with_priorities:
			if pt.target in survey.targets:
				var max_priority
				for survey_target in survey.targets:
					if !max_priority:
						max_priority = pt.priority
					elif pt.priority > max_priority:
						max_priority = pt.priority
		
		surveys_with_priorities.append(survey_with_priority)
					
	var selected_target_survey = select_by_priority(surveys_with_priorities)
	return selected_target_survey

func get_target_surveys(enemy: Character, targets_with_priorities: Array, ability: Dictionary) -> Array:
	var max_range = ability.range + Vector2i(1, 1)
	var target_surveys: Array
	var origin = enemy.grid_position
	
	for x in range(max_range.x + 1):
		for y in range(max_range.y + 1):
			var survey = {"ability": ability, "targets": [], "should_move": false}
			var cells = Utils.get_neighbor_coords(origin - Vector2i(x, y), ability.shape, max_range, Data.Alliance.ENEMY)
			for target_with_priority in targets_with_priorities: 
				var target = target_with_priority.target
				if target.grid_position in cells:
					if origin.x - target.grid_position.x == max_range.x || abs(origin.y - target.grid_position.x) == max_range.y:
						survey.should_move = true
					survey.targets.append(target)
			if !survey.targets.is_empty():
				target_surveys.append(survey)

	return target_surveys

func get_targets_with_priorities(targets) -> Array:
	var targets_with_priorities: Array
	targets.sort_custom(func(targetA, targetB): targetA.health_bar.value < targetB.health_bar.value)
	for i in range(targets.size()):
		var priority = i * 10
		targets_with_priorities.append({"target": targets[i], "priority": priority})
		
	return targets_with_priorities
	
func check_valid_move(origin: Vector2i, target_pos: Vector2i, range: Vector2i):
	if origin.x - range.x + 1 == target_pos.x && origin.x - 1 > 3:
		return Vector2i(origin.x - 1, origin.y)
	elif origin.y - range.x + 1 == target_pos.x && origin.x - 1 > 3:
		return Vector2i(origin.x - 1, origin.y)
	
func get_priority_move(players, enemy, selected_target) -> Vector2i:
	var current_x = enemy.grid_position.x
	var current_y = enemy.grid_position.y
	var enemy_positions: Array
	for player in players:
		if player.alliance == Data.Alliance.ENEMY:
			enemy_positions.append(player.grid_position)
	
	var next_pos: Vector2i
	if selected_target.grid_position.y - current_y > 1 && current_y < 4 && Vector2i(current_x, current_y + 1) not in enemy_positions:
		current_y += 1
	elif selected_target.grid_position.y - current_y < 1 && enemy.grid_position > 0 && Vector2i(current_x, current_y - 1) not in enemy_positions:
		current_y -= 1
	if current_x > 4 && Vector2i(current_x - 1, current_y) not in enemy_positions:
		current_x -= 1
	return Vector2i(current_x, current_y)
		
func get_targets(players: Array[Character], ability: Dictionary) -> Array:
	var targets: Array
	if ability.target_type == Data.TargetType.ENEMY:
		targets = players.filter(func(player): return player.alliance == Data.Alliance.HERO)
	elif ability.target_type == Data.TargetType.HERO:
		targets = players.filter(func(player): return player.alliance == Data.Alliance.ENEMY)
	return targets
		
func roll_dice(attempts: int, sides: int) -> int:
	var result = 0
	for i in range(attempts):
		var next_result = randi() % sides
		if next_result > result:
			result = next_result
	return result
