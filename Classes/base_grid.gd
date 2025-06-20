extends Node

class_name BaseGrid

var current_grid = {}

func set_object_at_grid_position(object: Node) -> void: # could eventually define non-char grid objects
	current_grid[object.grid_position] = object

func get_object_at_grid_position(position: Vector2i):
	var object = current_grid[position]
	if object:
		return object

func update_grid_object(object: Node, next_position: Vector2i) -> void:
	current_grid.erase(object.grid_position)
	object.set_grid_position(next_position)
	current_grid[next_position] = object
	
func populate_grid(objects: Array) -> void:
	for object in objects:
		set_object_at_grid_position(object)
		
func check_valid_targets(target_cells: Array, target_type: Data.TargetType, check_movement: bool = false) -> bool:
	var valid_targets: Array[Vector2i]
	var occupied_cells = current_grid.keys()
	
	if check_movement && occupied_cells.has(target_cells[0]):
		return false
	elif check_movement:
		return true
		
	for cell in occupied_cells:
		if target_type == Data.TargetType.ENEMY:
			if cell.x > 3: # (# of columns / 2) - 1
				valid_targets.append(cell)
		elif target_type == Data.TargetType.HERO:
			if cell.x < 4:
				valid_targets.append(cell)
				
	var is_valid_target: bool = false
	for cell in target_cells:
		if valid_targets.has(cell):
			is_valid_target = true
			
	return is_valid_target

func get_melee_targets(alliance: Data.Alliance, ability: Dictionary, player: Character) -> Array:
	var x_range: Vector2i
	if alliance == Data.Alliance.HERO:
		x_range = Vector2i(4,8) # hard coded
	elif alliance == Data.Alliance.ENEMY:
		x_range = Vector2i(0,4)
	
	var y_range = Vector2i(clamp(player.grid_position.y - ability.range.y, 0, 3), clamp(player.grid_position.y + ability.range.y, 0, 3))
		
	var occupied_cells = current_grid.keys()
	var target_cells: Array
	for y in range(y_range.x, y_range.y + 1):
		for x in range(x_range.x, x_range.y):
			var current_cell = Vector2i(x, y)
			if current_cell in occupied_cells:
				target_cells.append(current_cell)
				break
	return target_cells
