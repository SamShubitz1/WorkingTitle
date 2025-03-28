extends Node

func get_valid_targets(enemy: Character, targets: Array, ability: Dictionary) -> Array:
	var range = ability.range
	var valid_targets: Array
	for x in range(range.x):
		for y in range(range.y):
			var target_scan =  {"ability": ability, "targets": [], "origin": Vector2i(x, y)}
			var cells = Utils.get_neighbor_coords(enemy.grid_position, ability.shape, range)
			for cell in cells:
				for target in targets: 
					if target.grid_position == cell:
						target_scan.append(target)
			if !target_scan.targets.is_empty():
				valid_targets.append(target_scan)
	return valid_targets

func get_priority_target(targets: Array) -> Object:
	targets.sort_custom(func(targetA, targetB): targetA.health_bar.value < targetB.health_bar.value)
	var targets_with_priorities: Array
	for i in range(targets.size()):	
		var priority = i * 10
		targets_with_priorities.append({"target": targets[i], "priority": priority})
		
	var selected_target = select_by_priority(targets_with_priorities)
	return selected_target.target
		
func get_priority_ability(abilities: Array) -> Dictionary:
	abilities.sort_custom(func(abilityA, abilityB): abilityA.damage.value > abilityB.damage.value)
	var abilities_with_priorities: Array
	for i in range(abilities.size()):
		var priority = i * 10
		for effect in abilities[i].effects:
			priority += 10
		
		abilities_with_priorities.append({"ability": abilities[i], "priority": priority})
	
	var selected_ability = select_by_priority(abilities_with_priorities)
	return selected_ability.ability

func select_by_priority(objects_with_priorities):
	var selected_object: Dictionary
	var difference: int
	for object in objects_with_priorities:
		var result = roll_dice(3, 100)
		var next_difference = abs(result - object.priority)
		if !difference:
			difference = next_difference
			selected_object = object
		elif next_difference < difference:
			difference = next_difference
			selected_object = object
	
	return selected_object
	
func check_valid_move(origin: Vector2i, target_pos: Vector2i, range: Vector2i):
	if origin.x - range.x + 1 == target_pos.x && origin.x - 1 > 3:
		return Vector2i(origin.x - 1, origin.y)
	elif origin.y - range.x + 1 == target_pos.x && origin.x - 1 > 3:
		return Vector2i(origin.x - 1, origin.y)
	
func build_turn(enemy: Character, players: Array) -> Array:
	var enemy_turn: Array
	var ability: Dictionary = get_priority_ability(enemy.abilities)
	#var action = get_priority_action()
	var targets = get_targets(players, ability)
	var valid_targets = get_valid_targets(enemy, targets, ability)
	
	if valid_targets.is_empty():
		var selected_target = get_priority_target(targets)
		var next_pos = get_priority_move(players, enemy, selected_target)
		if next_pos != enemy.grid_position:
			enemy_turn.append({"type": Data.EnemyAction.MOVE, "position": next_pos})
	else:
		var selected_target = get_priority_target(valid_targets)
		enemy_turn.append({"type": Data.EnemyAction.ABILITY, "ability": ability, "target": selected_target})
		
	return enemy_turn
	
func get_priority_move(players, enemy, selected_target) -> Vector2i:
	var current_x = enemy.grid_position.x
	var current_y = enemy.grid_position.y
	clamp(current_x, 4, 7) # more hard coded grid size values
	clamp(current_y, 0, 3)
	var enemy_positions: Array
	for player in players:
		if player.alliance == Data.Alliance.ENEMY:
			enemy_positions.append(player.grid_position)
	
	var next_pos: Vector2i
	if selected_target.grid_position.y - enemy.grid_position.y > 1 && Vector2i(current_x, current_y + 1) not in enemy_positions:
		current_y += 1
	elif selected_target.grid_position.y - enemy.grid_position.y < 1 && Vector2i(current_x, current_y - 1) not in enemy_positions:
		current_y -= 1
	if enemy.grid_position.x > 4 && Vector2i(current_x - 1, current_y) not in enemy_positions:
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
