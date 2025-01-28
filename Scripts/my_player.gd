
extends CharacterBody2D

@export var DEBUG_PLAYER: bool = true

#TODO get from map_manager / map_controller
@onready var Current_Tile_Map = $"../MapController/TileMapLayer"
@onready var Map_Controller = $"../MapController"
var GRID_CELL_SIZE_PX: int = 16

@onready var Player_Animation_Object = $AnimatedSprite2D
@export var speed: int = 1
@export var player_image_offset_px = Vector2i(8,8)
var player_moving: bool = false
var dest_grid = Vector2i(0,0)
var player_grid = Vector2i(0,0)

enum Direction {
	UP,
	DOWN,
	LEFT,
	RIGHT,
	NONE
}
var player_direction: Direction = Direction.DOWN


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_grid = point_to_grid(position)
	Player_Animation_Object.play("idle_down")
	return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	#DEBUG hotkey for info print to console
	if (DEBUG_PLAYER and Input.is_action_just_pressed("testbutton")):
		print_player_info()

	process_player_movement(delta)
	process_player_inputs()
		# set_next_move(dir)
		# player_moving
	return

# translates input events to set_next_move function
#TODO possibly refactor for event / interrupt based input handling
func process_player_inputs() -> void:
	if Input.is_action_pressed("ui_up"):
		set_next_move(Direction.UP)
	elif Input.is_action_pressed("ui_down"):
		set_next_move(Direction.DOWN)
	elif Input.is_action_pressed("ui_left"):
		set_next_move(Direction.LEFT)
	elif Input.is_action_pressed("ui_right"):
		set_next_move(Direction.RIGHT)
	elif Input.is_action_just_pressed("ui_accept"):
		player_action_pressed()
	return # end process_player_inputs()

# set all values before process_player_movement() operates on incoming move command
func set_next_move(dir: Direction) -> void:
	if player_moving:
		# already moving, exit this function
		return

	# set player direction
	player_direction = dir

	# various direction conditionals
	# sets destination grid, sets animations
	match dir:
		Direction.UP:
			dest_grid.y -= 1
			Player_Animation_Object.play("walk_up")
		Direction.DOWN:
			dest_grid.y += 1
			Player_Animation_Object.play("walk_down")
		Direction.LEFT:
			dest_grid.x -= 1
			Player_Animation_Object.play("walk_side")
			Player_Animation_Object.flip_h = true
		Direction.RIGHT:
			dest_grid.x += 1
			Player_Animation_Object.play("walk_side")
			Player_Animation_Object.flip_h = false
		_:
			#TODO catch error for bad input value on dir
			print("ERROR: Bad direction input given to player on set_next_move(dir)")

	# check if next move is valid
	if (check_grid_for_collider(dest_grid)):
		# collider found, reset move state and values, and exit early
		if (DEBUG_PLAYER): print("Player collision at cell: " + str(dest_grid))
		player_moving = false
		dest_grid = player_grid
		check_move_complete()
		return # collider found, return early to stop moving

	# set player as moving, do not process new movements until this move completes
	player_moving = true

	return

func process_player_movement(_delta) -> void:
	if not player_moving:
		# no move command to operate on, exit
		return

	# method 1 - move_and_collide
	#var collision = move_and_collide(velocity * delta)

	# method 2 - move_and_slide
	# move_and_slide()
	# var collision
	# if get_slide_collision_count() > 0:
	#     collision = get_slide_collision(0)
	# if collision:
	#     print("player collision: " + str(collision))

	# method 3 - non-physics, just peek at next tile for collider
	match player_direction:
		Direction.UP:
			position.y -= speed
		Direction.DOWN:
			position.y += speed
		Direction.LEFT:
			position.x -= speed
		Direction.RIGHT:
			position.x += speed
		_:
			#TODO catch error for bad player dir
			print("ERROR: Bad direction on player process_player_movement()")

	# update player grid coords reference
	player_grid = point_to_grid(position)

	# check if at destination
	check_move_complete()

	return # end process_player_movement()

func check_grid_for_collider(grid_coords: Vector2i) -> bool:
	# safe input check: grid_coords
	if (grid_coords.x < 0 or grid_coords.y < 0):
		#TODO catch error for out-of-bounds array lookup for tilemap object
		print("ERROR: bad TileMap lookup coords: " + str(grid_coords))
		return true # exit for bad value

	# get tile at grid_coords
	var tile_data = Current_Tile_Map.get_cell_tile_data(grid_coords)
	if (tile_data == null):
		#TODO catch error for out-of-bounds array lookup for tilemap object
		print("ERROR: bad TileMap lookup coords: " + str(grid_coords))
		return true # exit for bad TileMap data
	# check tile for collider
	var collider_count = tile_data.get_collision_polygons_count(0)
	# return result: true = collider, false = no collider
	return collider_count

# check if player is at destination
func check_move_complete() -> void:
	var move_finished: bool = false # local/temp var for tracking move state

	match player_direction:
		Direction.UP:
			if (position.y <= ((dest_grid.y * GRID_CELL_SIZE_PX) + player_image_offset_px.y)):
				# AT UP DEST
				move_finished = true
				Player_Animation_Object.play("idle_up")
		Direction.DOWN:
			if (position.y >= ((dest_grid.y * GRID_CELL_SIZE_PX) + player_image_offset_px.y)):
				# AT DOWN DEST
				move_finished = true
				Player_Animation_Object.play("idle_down")
		Direction.LEFT:
			if (position.x <= ((dest_grid.x * GRID_CELL_SIZE_PX) + player_image_offset_px.x)):
				# AT LEFT DEST
				move_finished = true
				Player_Animation_Object.play("idle_side")
				Player_Animation_Object.flip_h = true # flip side image for left
		Direction.RIGHT:
			if (position.x >= ((dest_grid.x * GRID_CELL_SIZE_PX) + player_image_offset_px.x)):
				# AT RIGHT DEST
				move_finished = true
				Player_Animation_Object.play("idle_side")
				# no flip side image for right
		_:
			#TODO catch error for bad player dir
			print("ERROR: Bad direction on player check_move_complete()")

	if (move_finished):
		player_moving = false
		position = grid_to_point(dest_grid) # force player position to dest point
		player_grid = point_to_grid(position) # update reference to player grid

	return

# translate from world_coordinates to grid_coordinates
func point_to_grid(point_coords: Vector2i) -> Vector2i:
	var x = round((point_coords.x - player_image_offset_px.x) / GRID_CELL_SIZE_PX)
	var y = round((point_coords.y - player_image_offset_px.y) / GRID_CELL_SIZE_PX)
	return Vector2i(x,y)

# translate from grid_coordinates to world_coordinates
func grid_to_point(grid_coords: Vector2i) -> Vector2i:
	var x = round((grid_coords.x * GRID_CELL_SIZE_PX) + player_image_offset_px.x)
	var y = round((grid_coords.y * GRID_CELL_SIZE_PX) + player_image_offset_px.y)
	return Vector2i(x,y)


#DEBUG player debug print to console
func print_player_info() -> void:

	var tile = Current_Tile_Map.get_cell_tile_data(player_grid)
	var tile_collider_count = tile.get_collision_polygons_count(0)

	var player_info_report = {
		"player_moving": player_moving,
		"player_direction": Direction.keys()[player_direction],
		"player_world_coords": position,
		"dest_grid_coords": dest_grid,
		"player_grid_cords": player_grid,
		"tile_colliders_on_player_point": tile_collider_count
	}
	print("player_info: " + str(player_info_report))

	return

func player_action_pressed() -> void:

	# get action coords
	var action_coords = player_grid
	match player_direction:
		Direction.UP:
			action_coords.y -= 1
		Direction.DOWN:
			action_coords.y += 1
		Direction.LEFT:
			action_coords.x -= 1
		Direction.RIGHT:
			action_coords.x += 1
	
	# get tile
	var tile = Current_Tile_Map.get_cell_tile_data(action_coords)
	if (tile == null):
		#TODO catch error
		print("ERROR: Inspecting null tile at: " + str(action_coords))
		return # bad value, exit

	# get tile info
	var tile_report = {
		"world_coords": grid_to_point(action_coords),
		"map_coords": action_coords,
		"colliders_count": tile.get_collision_polygons_count(0),
		"custom_data": tile.get_custom_data("layer_name"),
		"texture_origin": tile.texture_origin,
		"cell_atlas_coords": Current_Tile_Map.get_cell_atlas_coords(action_coords)
	}

	print("action_button: " + str(tile_report))
	
	var test = Map_Controller.set_object_at_coordinates(self, action_coords)
	
	var object = Map_Controller.get_object_at_coordinates(action_coords)
	print("returned object: ", object)

	return
