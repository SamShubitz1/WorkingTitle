extends Node

class_name BaseGrid

var current_grid = {}

func _init() -> void:
	for y in range(Data.grid_size.y):
		for x in range(Data.grid_size.x):
			current_grid[Vector2i(x,y)] = BaseGridCell.new()

func set_terrain(terrain: Dictionary) -> void:
	if terrain.is_empty():
		return
				
	for type in terrain.keys():
		for cell in terrain[type]:
			current_grid[cell].terrain = type
	
func set_object_at_grid_position(object: Node) -> void: # could eventually define non-char grid objects
	current_grid[object.grid_position].character = object
	
	print("Current grid after set object at grid position:")
	print_grid()

func get_object_at_grid_position(position: Vector2i) -> Node:
	var object = current_grid[position].character
	if object:
		return object
	return null

func update_grid_object(object: Node, next_position: Vector2i) -> void:
	current_grid.erase(object.grid_position)
	object.set_grid_position(next_position)
	current_grid[next_position].character = object
	
func populate_grid(objects: Array) -> void:
	for object in objects:
		set_object_at_grid_position(object)

func set_position_by_grid_coords(character: Character) -> void:
	var y_offsets = {0: 405, 1: 340, 2: 283, 3: 230}
	var x_offsets = {0: 50, 1: 80, 2: 100, 3: 120 }
	var enemy_x_offset = 60
	var coords = character.grid_position
	var x_pos = 50 + (coords.x * 126) # const grid_span_x = 126, const grid_offset_y = -110
	var y_pos = 400 + (coords.y * -110)
	if character.alliance == Data.Alliance.ENEMY:
		x_pos += enemy_x_offset
		x_offsets[0] += 130
		x_offsets[1] += 70
		x_offsets[2] += 30
	character.position = Vector2i(x_pos + x_offsets[coords.y], y_offsets[coords.y])

func get_melee_targets(alliance: Data.Alliance, ability: Dictionary, player: Character) -> Array:
	var x_range: Vector2i
	if alliance == Data.Alliance.HERO:
		x_range = Vector2i(4,8) # hard coded
	elif alliance == Data.Alliance.ENEMY:
		x_range = Vector2i(0,4)
	
	var y_range = Vector2i(clamp(player.grid_position.y - ability.range.y, 0, 3), clamp(player.grid_position.y + ability.range.y, 0, 3))
		
	var occupied_cells = get_occupied_cells()
	var target_cells: Array
	for y in range(y_range.x, y_range.y + 1):
		for x in range(x_range.x, x_range.y):
			var current_cell = Vector2i(x, y)
			if current_cell in occupied_cells:
				target_cells.append(current_cell)
				break
	return target_cells

func get_occupied_cells() -> Array[Vector2i]:
	var occupied_cells: Array[Vector2i]
	for cell in current_grid.keys():
		if current_grid[cell].character != null:
			occupied_cells.append(cell)
	return occupied_cells

func print_grid() -> void:
	for cell in current_grid.keys():
		print("Cell: ", cell)
		var character = "none" if current_grid[cell].character == null else current_grid[cell].character.char_name
		print("Character: ", character)
		var terrain = "None" if current_grid[cell].terrain == 0 else "Blocked"
		print("Terrain: ", terrain)
