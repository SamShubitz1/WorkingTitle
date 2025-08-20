extends BaseMenu

class_name BaseGridMenu

enum GridType {
	GLOBAL,
	ENEMY,
	HERO,
	CUSTOM
}

const grid_size := Data.grid_size

var battle_grid: Dictionary
var targets_grid: Dictionary
var grid_type: GridType
var range_of_movement: Vector2i
var selected_coords: Vector2i
var origin: Vector2i

var current_shape: GameData.AbilityShape
var custom_index = 0
	
func init(menu: Node, cells: Array, menu_cursor: BaseCursor, initial_button_position = null) -> void:
	super.init(menu, cells, menu_cursor)
	build_grid()
	reset_cells()
	
func build_grid():
	var cell_index = 0
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var grid_coords = Vector2i(x, grid_size.y - (y + 1))
			targets_grid[grid_coords] = {"node": buttons[cell_index], "active": false, "terrain": Data.BattleTerrain.NONE}
			cell_index += 1

func reset_cells() -> void:
	for cell in targets_grid:
		match targets_grid[cell].terrain:
			Data.BattleTerrain.NONE:
				targets_grid[cell].node.modulate = Color(0, 0, 0, 0.1)
			Data.BattleTerrain.BLOCKED:
				targets_grid[cell].node.modulate = Color(0, 0, 0, 0)
	
func set_custom_cells(custom_cells: Array):
	for cell in targets_grid:
		if cell in custom_cells:
			targets_grid[cell].active = true
		else:
			targets_grid[cell].active = false
	
func activate_enemy_grid() -> void:
	grid_type = GridType.ENEMY
	for cell in targets_grid:
		if cell.x > 3 && targets_grid[cell].terrain != Data.BattleTerrain.BLOCKED:
			targets_grid[cell].active = true
		else:
			targets_grid[cell].active = false
	
func activate_hero_grid() -> void:
	grid_type = GridType.HERO
	for cell in targets_grid:
		if cell.x < 4 && targets_grid[cell].terrain != Data.BattleTerrain.BLOCKED:
			targets_grid[cell].active = true
		else:
			targets_grid[cell].active = false
	
func get_target_cells() -> Array:
	var target_coords = Utils.get_neighbor_coords(selected_coords, current_shape, Data.Alliance.HERO)
	
	var active_cells: Array
	for coord in target_coords:
		if targets_grid[coord].active:
			active_cells.append(coord)
			
	return active_cells
	
#func set_guarded_cells(coords: Vector2i) -> void:
	#var guarded_cells: Array
	#for i in range(coords.x + 1):
		#guarded_cells.append(Vector2i(coords.x - i, coords.y))
	#for cell in guarded_cells:
		#targets_grid[cell].modulate = Color(1.0, 0.84, 0.0)
	
func navigate_forward(e: InputEvent) -> void:
	if !is_active:
		return
		
	#if current_grid_type == GridType.CUSTOM:
		#var next_index = (custom_index + 1) % targets_grid.size()
		#custom_index = next_index
		#update_selected_cell(targets_grid.keys()[custom_index])
		#return
		
	elif e.keycode == KEY_DOWN || e.keycode == KEY_S: 
		move_down()
	elif e.keycode == KEY_RIGHT || e.keycode == KEY_D:
		move_right()
			
func navigate_backward(e: InputEvent) -> void:
	if !is_active:
		return
		
	#if current_grid_type == GridType.CUSTOM:
		#if custom_index > 0:
			#custom_index -= 1
		#else:
			#custom_index = targets_grid.size() - 1
		#update_selected_cell(targets_grid.keys()[custom_index])
		
	elif e.keycode == KEY_UP || e.keycode == KEY_W:
		move_up()
	elif e.keycode == KEY_LEFT || e.keycode == KEY_A:
		move_left()

func move_up() -> void:
	if selected_coords.y == grid_size.y - 1:
		return
		
	var next_coords := Vector2i(selected_coords.x, selected_coords.y + 1)
	if !targets_grid[next_coords].active:
		return #add logic to get next valid cell
		
	var is_in_range = check_range(next_coords)
	if !is_in_range:
		return
		
	update_selected_cell(next_coords)

func move_down() -> void:
	if selected_coords.y == 0:
		return
		
	var next_coords := Vector2i(selected_coords.x, selected_coords.y - 1)
	if !targets_grid[next_coords].active:
		return #add logic to get next valid cell
		
	var is_in_range = check_range(next_coords)
	if !is_in_range:
		return
		
	update_selected_cell(next_coords)

func move_left() -> void:
	if selected_coords.x == 0:
		return

	var next_coords := Vector2i(selected_coords.x - 1, selected_coords.y)
	if !targets_grid[next_coords].active:
		return #add logic to get next valid cell
		
	var is_in_range = check_range(next_coords)
	if !is_in_range:
		return
		
	update_selected_cell(next_coords)

func move_right() -> void:
	if selected_coords.x == 7:
		return

	var next_coords := Vector2i(selected_coords.x + 1, selected_coords.y)
	if !targets_grid[next_coords].active:
		return #add logic to get next valid cell
		
	var is_in_range = check_range(next_coords)
	if !is_in_range:
		return
		
	update_selected_cell(next_coords)
	
func activate() -> void:
	self.show_menu()
	is_active = true
	cursor.move_cursor(selected_button.position)

func disactivate() -> void:
	is_active = false
	reset_cells()

func update_selected_cell(next_coords) -> void:
	reset_cells()
	var neighbor_coords = Utils.get_neighbor_coords(next_coords, current_shape, Data.Alliance.HERO)
	for coords in neighbor_coords:
		if !targets_grid.has(coords):
			continue
		var neighbor = targets_grid[coords]
		if neighbor.active:
			neighbor.node.modulate = get_cell_color(coords, true)
			
	selected_coords = next_coords
	targets_grid[selected_coords].node.modulate = get_cell_color(selected_coords, false)
	
func set_current_shape(attack_shape: Data.AbilityShape) -> void:
	current_shape = attack_shape

func update_terrain() -> void:
	for cell in battle_grid:
		targets_grid[cell].terrain = battle_grid[cell].terrain

func set_range(next_origin: Vector2i, range: Vector2i) -> void:
	self.origin = next_origin
	range_of_movement = range
	if grid_type == GridType.HERO:
		update_selected_cell(origin)
	elif grid_type == GridType.ENEMY:
		update_selected_cell(Vector2i(4, origin.y))

func get_cell_color(coords: Vector2i, is_neighbor: bool) -> Color:
	var opacity := 0.5 if is_neighbor else 0.6
	if coords.x > 3:
		return Color(1, 0, 0, opacity)
	else:
		return Color(0.5, 0.2, 1, opacity)
		
func check_range(coords: Vector2i):
	if abs(coords.x - origin.x) > range_of_movement.x:
		return false
	elif abs(coords.y - origin.y) > range_of_movement.y:
		return false
	else:
		return true

func _on_terrain_change(grid: Dictionary) -> void:
	battle_grid = grid
	update_terrain()
	reset_cells()
