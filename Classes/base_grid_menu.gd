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
const initial_grid_size: Vector2i = Vector2i(8, 4)

func init(menu: Node, menu_buttons: Array, menu_cursor: BaseCursor, initial_button_position = null) -> void:
	super.init(menu, menu_buttons, menu_cursor)
	update_grid(initial_grid_size)
	
func update_grid(grid_size: Vector2i):
	targets_grid = {}
	var rows = grid_size.y
	var columns = grid_size.x
	var cell_index = 0
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var grid_coords = Vector2i((columns - (columns - x)), rows - (y + 1))
			targets_grid[grid_coords] = buttons[cell_index]
			cell_index += 1
			
func activate_enemy_grid() -> void:
	var next_grid_size = Vector2i(initial_grid_size.x / 2, initial_grid_size.y)
	var enemy_grid: Array
	for y in range(next_grid_size.y):
		for x in range(next_grid_size.x):
			enemy_grid.append(targets_grid[Vector2i(x + next_grid_size.x, (initial_grid_size.y - 1) - y)])
	buttons = enemy_grid
	set_scroll_size(buttons.size())
	set_grid_type(GridType.ENEMY)
	update_grid(next_grid_size)
	
func activate_player_grid() -> void:
	var next_grid_size = Vector2i(initial_grid_size.x / 2, initial_grid_size.y)
	var enemy_grid: Array
	for y in range(next_grid_size.y):
		for x in range(next_grid_size.x):
			enemy_grid.append(targets_grid[Vector2i(x, y)])
	buttons = enemy_grid
	set_scroll_size(buttons.size())
	set_grid_type(GridType.PLAYER)
	update_grid(next_grid_size)

func get_selected_grid_coords() -> Vector2i:
	var coords = targets_grid.find_key(selected_button)
	if current_grid_type == GridType.ENEMY:
		coords.x += initial_grid_size.x / 2 #assumes grid coords will always be 8x4
	return coords

func navigate_forward(e: InputEvent) -> void:
	if e.keycode == KEY_DOWN || e.keycode == KEY_S:
		move_down()
	elif e.keycode == KEY_RIGHT || e.keycode == KEY_D:
		move_right()
			
func navigate_backward(e: InputEvent) -> void:
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
	selected_button = targets_grid[next_coords]
	cursor.move_cursor(selected_button.position)

func move_down() -> void:
	var coords = targets_grid.find_key(selected_button)
	var next_coords: Vector2i
	if coords.y == 0: # should be a dynamic value
		next_coords = Vector2i(coords.x, 3)
	else:
		next_coords = Vector2i(coords.x, coords.y - 1)
	selected_button = targets_grid[next_coords]
	cursor.move_cursor(selected_button.position)

func move_left() -> void:
	var coords = targets_grid.find_key(selected_button)
	var next_coords: Vector2i
	if coords.x == 0: # should be a dynamic value
		next_coords = Vector2i(3, coords.y)
	else:
		next_coords = Vector2i(coords.x - 1, coords.y)
	selected_button = targets_grid[next_coords]
	cursor.move_cursor(selected_button.position)

func move_right() -> void:
	var coords = targets_grid.find_key(selected_button)
	var next_coords: Vector2i
	if coords.x == 3: # should be a dynamic value
		next_coords = Vector2i(0, coords.y)
	else:
		next_coords = Vector2i(coords.x + 1, coords.y)
	selected_button = targets_grid[next_coords]
	cursor.move_cursor(selected_button.position)
	
func set_grid_type(type: GridType) -> void:
	current_grid_type = type
