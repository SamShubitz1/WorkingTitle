extends BaseMenu

class_name BaseGridMenu

enum GridType {
	GLOBAL,
	ENEMY,
	HERO
}

enum Direction {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

var targets_grid: Dictionary = {}
var current_grid_type: GridType = GridType.GLOBAL
var global_cells: Array[Panel]
var range_of_movement: Vector2i
var origin: Vector2i
var wrap: bool

const initial_grid_size: Vector2i = Vector2i(8, 4)

var current_shape: GameData.AbilityShape

func init(menu: Node, buttons: Array, menu_cursor: BaseCursor, initial_button_position = null, wrap = true) -> void:
	super.init(menu, buttons, menu_cursor)
	self.wrap = wrap
	global_cells = buttons
	update_grid(initial_grid_size)
	for button in buttons:
		button.modulate = Color(0, 0, 0)
		button.modulate.a = .1
	
func update_grid(grid_size: Vector2i):
	targets_grid = {}
	var rows = grid_size.y
	var cell_index = 0
	for y in range(rows):
		for x in range(grid_size.x):
			var grid_coords = Vector2i(x, rows - (y + 1))
			targets_grid[grid_coords] = buttons[cell_index]
			cell_index += 1

func activate_enemy_grid() -> void:
	if current_grid_type != GridType.ENEMY:
		var next_grid_size = Vector2i(initial_grid_size.x / 2, initial_grid_size.y)
		var enemy_grid = get_enemy_cells()
		buttons = enemy_grid
		set_scroll_size(buttons.size())
		set_grid_type(GridType.ENEMY)
		update_grid(next_grid_size)

func activate_hero_grid() -> void:
	if current_grid_type != GridType.HERO:
		var next_grid_size = Vector2i(initial_grid_size.x / 2, initial_grid_size.y)
		var player_grid = get_player_cells()
		buttons = player_grid
		set_scroll_size(buttons.size())
		set_grid_type(GridType.HERO)
		update_grid(next_grid_size)
		
func get_enemy_cells() -> Array:
	var enemy_cells: Array
	var columns = initial_grid_size.x
	for i in range(global_cells.size()):
		if i % columns == columns / 2:
			for j in range(columns / 2):
				enemy_cells.append(global_cells[i + j])
	return enemy_cells
				
func get_player_cells() -> Array:
	var player_cells: Array
	var columns = initial_grid_size.x
	for i in range(global_cells.size()):
		if i % columns == 0:
			for j in range(columns / 2):
				player_cells.append(global_cells[i + j])
	return player_cells
		
func get_targeted_cell_coords() -> Array:
	var selected_coords = [targets_grid.find_key(selected_button)]
	selected_coords.append_array(get_neighbor_coords(selected_coords[0]))
	var global_coords: Array
	if current_grid_type == GridType.ENEMY:
		for coord in selected_coords:
			coord.x += 4
			global_coords.append(coord)
		selected_coords = global_coords
	return selected_coords
	
func set_guarded_cells(coords: Vector2i) -> void:
	var guarded_cells: Array
	for i in range(coords.x + 1):
		guarded_cells.append(Vector2i(coords.x - i, coords.y))
	for cell in guarded_cells:
		targets_grid[cell].modulate = Color(1.0, 0.84, 0.0)

func navigate_forward(e: InputEvent) -> void:
	if is_active:
		if e.keycode == KEY_DOWN || e.keycode == KEY_S:
			move_down()
		elif e.keycode == KEY_RIGHT || e.keycode == KEY_D:
			move_right()
			
func navigate_backward(e: InputEvent) -> void:
	if is_active:
		if e.keycode == KEY_UP || e.keycode == KEY_W:
			move_up()
		elif e.keycode == KEY_LEFT || e.keycode == KEY_A:
			move_left()

func move_up() -> void:
	var coords = targets_grid.find_key(selected_button)
	var next_coords: Vector2i
	
	if coords.y == initial_grid_size.y - 1 && wrap:
		next_coords = Vector2i(coords.x, 0)
	elif coords.y == initial_grid_size.y - 1 && !wrap:
		next_coords = coords
	else:
		next_coords = Vector2i(coords.x, coords.y + 1)
		
	var is_in_range = check_range(next_coords)
	if !is_in_range:
		return
		
	update_selected_cell(next_coords)

func move_down() -> void:
	var coords = targets_grid.find_key(selected_button)
	var next_coords: Vector2i
	if coords.y == 0 && wrap:
		next_coords = Vector2i(coords.x, 3)
	elif coords.y == 0 && !wrap:
		next_coords = coords
	else:
		next_coords = Vector2i(coords.x, coords.y - 1)
	var is_in_range = check_range(next_coords)
	if !is_in_range:
		return
	selected_button.modulate.a = 0
	update_selected_cell(next_coords)

func move_left() -> void:
	var coords = targets_grid.find_key(selected_button)
	var next_coords: Vector2i
	if coords.x == 0 && wrap:
		next_coords = Vector2i((initial_grid_size.x / 2) - 1, coords.y)
	elif coords.x == 0 && !wrap:
		next_coords = coords
	else:
		next_coords = Vector2i(coords.x - 1, coords.y)
	if !wrap:
		var is_in_range = check_range(next_coords)
		if !is_in_range:
			return
	selected_button.modulate.a = 0
	update_selected_cell(next_coords)

func move_right() -> void:
	var coords = targets_grid.find_key(selected_button)
	var next_coords: Vector2i
	if coords.x == 3 && wrap: # should be a dynamic value
		next_coords = Vector2i(0, coords.y)
	elif coords.x == 3 && !wrap:
		next_coords = coords
	else:
		next_coords = Vector2i(coords.x + 1, coords.y)
	var is_in_range = check_range(next_coords)
	if !is_in_range:
		return
	selected_button.modulate.a = 0
	update_selected_cell(next_coords)

func set_grid_type(type: GridType) -> void:
	current_grid_type = type
	
func activate() -> void:
	self.show_menu()
	is_active = true
	cursor.move_cursor(selected_button.position)

func disactivate() -> void:
	is_active = false
	reset_cells()
	
func update_selected_cell(next_coords) -> void:
	reset_cells()
	var neighbor_coords = get_neighbor_coords(next_coords)
	for coords in neighbor_coords:
		var neighbor = targets_grid[coords]
		neighbor.modulate = get_cell_color()
		neighbor.modulate.a = 0.5
	selected_button = targets_grid[next_coords]
	selected_button.modulate = get_cell_color()
	selected_button.modulate.a = 0.6
	
func set_current_shape(attack_shape: Data.AbilityShape) -> void:
	current_shape = attack_shape

func get_neighbor_coords(origin_coords: Vector2i) -> Array:
	var neighbor_coords: Array
	match current_shape:
		GameData.AbilityShape.SINGLE:
			return neighbor_coords
		GameData.AbilityShape.DIAMOND:
			if origin_coords.y < initial_grid_size.y - 1:
				neighbor_coords.append(Vector2i(origin_coords.x, origin_coords.y + 1))
			if origin_coords.y > 0:
				neighbor_coords.append(Vector2i(origin_coords.x, origin_coords.y - 1))
			if origin_coords.x < initial_grid_size.x / 2 - 1: # if enemy origin active
				neighbor_coords.append(Vector2i(origin_coords.x + 1, origin_coords.y))
			if origin_coords.x > 0:
				neighbor_coords.append(Vector2i(origin_coords.x - 1, origin_coords.y))
		GameData.AbilityShape.LINE:
			var col_index = 0
			while col_index < initial_grid_size.x / 2:
				if col_index != origin_coords.x:
					neighbor_coords.append(Vector2i(col_index, origin_coords.y))
				col_index += 1
		GameData.AbilityShape.ALL:
			return targets_grid.keys()

	return neighbor_coords

func reset_cells() -> void:
	for button in buttons:
		button.modulate = Color(0, 0, 0)
		button.modulate.a = .1
		
func set_range(origin: Vector2i, range: Vector2i) -> void:
	self.origin = origin
	range_of_movement = range
	if current_grid_type == GridType.HERO:
		update_selected_cell(origin)
	else:
		update_selected_cell(Vector2i(0, origin.y))

func get_cell_color() -> Color:
	if current_grid_type == GridType.ENEMY:
		return Color(1, 0, 0)
	else:
		return Color(0.5, 0.7, 1)
		
func check_range(coords: Vector2i):
	#if range_of_movement == null:
		#return true
	if current_grid_type == GridType.ENEMY: 
		coords.x += (initial_grid_size.x / 2)
	if abs(coords.x - origin.x) > range_of_movement.x:
		return false
	elif abs(coords.y - origin.y) > range_of_movement.y:
		return false
	else:
		return true
