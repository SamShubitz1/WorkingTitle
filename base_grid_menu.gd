extends BaseMenu

class_name BaseGridMenu

var targets_grid: Dictionary = {}
const initial_grid_size: Vector2i = Vector2i(8, 2)

func init(menu: Node, menu_buttons: Array, menu_cursor: BaseCursor, initial_button_position = null) -> void:
	super.init(menu, menu_buttons, menu_cursor)
	update_grid(initial_grid_size)
	
func update_grid(grid_size: Vector2i):
	var cell_index = 0
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var rows = grid_size.y
			var columns = grid_size.x
			var grid_coords = Vector2i((columns - (columns - x)), rows - (y + 1))
			targets_grid[grid_coords] = buttons[cell_index]
			cell_index += 1
			
func activate_enemy_grid() -> void:
	var next_grid_size = Vector2i(initial_grid_size.x / 2, initial_grid_size.y)
	var enemy_grid: Array
	for y in range(next_grid_size.y):
		for x in range(next_grid_size.x):
			enemy_grid.append(targets_grid[Vector2i(x,y)])
	buttons = enemy_grid
	set_scroll_size(buttons.size())
	update_grid(next_grid_size)
	
	
