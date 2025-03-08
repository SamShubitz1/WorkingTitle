extends BaseMenu

class_name BaseGridMenu

enum GridType {
	GLOBAL,
	ENEMY,
	PLAYER
}

enum Direction {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

var targets_grid: Dictionary = {}
var current_grid_type: GridType = GridType.GLOBAL
var initial_cells: Array[Panel]
const initial_grid_size: Vector2i = Vector2i(8, 4)

var current_shape: GameData.AttackShapes

func init(menu: Node, menu_buttons: Array, menu_cursor: BaseCursor, initial_button_position = null) -> void:
	super.init(menu, menu_buttons, menu_cursor)
	initial_cells = menu_buttons
	update_grid(initial_grid_size)
	for button in menu_buttons:
		button.modulate.a = .1
	
func update_grid(grid_size: Vector2i):
	targets_grid = {}
	var rows = grid_size.y
	var cell_index = 0
	for y in range(grid_size.y):
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

func activate_player_grid() -> void:
	if current_grid_type != GridType.PLAYER:
		var next_grid_size = Vector2i(initial_grid_size.x / 2, initial_grid_size.y)
		var player_grid = get_player_cells()
		buttons = player_grid
		set_scroll_size(buttons.size())
		set_grid_type(GridType.PLAYER)
		update_grid(next_grid_size)
		
func get_enemy_cells() -> Array:
	var enemy_cells: Array
	var columns = initial_grid_size.x
	var rows = initial_grid_size.y
	for i in range(initial_cells.size()):
		if i % columns == columns / 2:
			for j in range(columns / 2):
				enemy_cells.append(initial_cells[i + j])
	return enemy_cells
				
func get_player_cells() -> Array:
	var enemy_cells: Array
	var columns = initial_grid_size.x
	var rows = initial_grid_size.y
	for i in range(initial_cells.size()):
		if i % columns == 0:
			for j in range(columns / 2):
				enemy_cells.append(initial_cells[i + j])
	return enemy_cells
		
func get_targeted_cells() -> Array:
	var selected_coords = [targets_grid.find_key(selected_button)]
	selected_coords.append_array(get_neighbor_coords(selected_coords[0]))
	var global_coords: Array
	for coord in selected_coords:
		coord.x += 4
		global_coords.append(coord)
	return global_coords

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
	if coords.y == 3: # should be a dynamic value
		next_coords = Vector2i(coords.x, 0)
	else:
		next_coords = Vector2i(coords.x, coords.y + 1)
	update_selected_cell(next_coords)
	
func move_down() -> void:
	var coords = targets_grid.find_key(selected_button)
	var next_coords: Vector2i
	if coords.y == 0: # should be a dynamic value
		next_coords = Vector2i(coords.x, 3)
	else:
		next_coords = Vector2i(coords.x, coords.y - 1)
	update_selected_cell(next_coords)

func move_left() -> void:
	var coords = targets_grid.find_key(selected_button)
	var next_coords: Vector2i
	if coords.x == 0: # should be a dynamic value
		next_coords = Vector2i(3, coords.y)
	else:
		next_coords = Vector2i(coords.x - 1, coords.y)
	update_selected_cell(next_coords)

func move_right() -> void:
	var coords = targets_grid.find_key(selected_button)
	var next_coords: Vector2i
	if coords.x == 3: # should be a dynamic value
		next_coords = Vector2i(0, coords.y)
	else:
		next_coords = Vector2i(coords.x + 1, coords.y)
	selected_button.modulate.a = 0
	update_selected_cell(next_coords)

func set_grid_type(type: GridType) -> void:
	current_grid_type = type
	
func activate() -> void:
	self.show_menu()
	is_active = true
	update_selected_cell(Vector2i.ZERO)
	cursor.move_cursor(selected_button.position)

func disactivate() -> void:
	is_active = false
	reset_cells()
	
func update_selected_cell(next_coords) -> void:
	reset_cells()
	var neighbor_coords = get_neighbor_coords(next_coords)
	for coords in neighbor_coords:
		var neighbor = targets_grid[coords]
		neighbor.modulate = Color(1, 1, 0, .3)
	selected_button = targets_grid[next_coords]
	selected_button.modulate.a = 0.5
	
func set_current_shape(attack_shape: GameData.AttackShapes) -> void:
	current_shape = attack_shape

func get_neighbor_coords(origin_coords: Vector2i) -> Array:
	var neighbor_coords: Array
	match current_shape:
		GameData.AttackShapes.DIAMOND:
			if origin_coords.y < initial_grid_size.y - 1:
				neighbor_coords.append(Vector2i(origin_coords.x, origin_coords.y + 1))
			if origin_coords.y > 0:
				neighbor_coords.append(Vector2i(origin_coords.x, origin_coords.y - 1))
			if origin_coords.x < initial_grid_size.x / 2 - 1: # if enemy origin active
				neighbor_coords.append(Vector2i(origin_coords.x + 1, origin_coords.y))
			if origin_coords.x > 0:
				neighbor_coords.append(Vector2i(origin_coords.x - 1, origin_coords.y))
	match current_shape:
		GameData.AttackShapes.LINE:
			var count = origin_coords.x + 1
			while count < initial_grid_size.x / 2:
				neighbor_coords.append(Vector2i(count, origin_coords.y))
				count += 1

	return neighbor_coords

func reset_cells() -> void:
	for button in buttons:
		button.modulate.a = 0.1
