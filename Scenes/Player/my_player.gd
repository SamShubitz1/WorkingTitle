extends CharacterBody2D

@onready var Player_Animation_Object = $AnimatedSprite2D
@onready var Map_Controller = $"../MapController"

@export var DEBUG_PLAYER: bool = true
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
	player_grid = Map_Controller.point_to_grid(position)
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

	# sets destination grid
	match dir:
		Direction.UP:
			dest_grid.y -= 1
		Direction.DOWN:
			dest_grid.y += 1
		Direction.LEFT:
			dest_grid.x -= 1
		Direction.RIGHT:
			dest_grid.x += 1
		_:
			#TODO catch error for bad input value on dir
			print("ERROR: Bad direction input given to player on set_next_move(dir)")

	# set player animation based on direction
	set_player_animation(player_direction, false)

	# check if next move is valid
	if (Map_Controller.check_grid_for_collider(dest_grid)):
		# collider found, reset move state and values, and exit early
		if (DEBUG_PLAYER): print("Player collision at cell: " + str(dest_grid))
		player_moving = false
		dest_grid = player_grid
		check_move_complete()
		return # collider found, return early to stop moving

	# set player as moving, do not process new movements until this move completes
	player_moving = true
	return

# move player
func process_player_movement(_delta) -> void:
	if not player_moving:
		# no move command to operate on, exit
		return

	# move player object by speed value
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
	player_grid = Map_Controller.point_to_grid(position, player_image_offset_px)
	# check if at destination
	check_move_complete()
	return # end process_player_movement()

# check if player is at destination
func check_move_complete() -> void:
	var move_finished: bool = false # local/temp var for tracking move state

	match player_direction:
		Direction.UP:
			if (position.y <= ((dest_grid.y * Map_Controller.GRID_CELL_SIZE_PX) + player_image_offset_px.y)):
				# AT UP DEST
				move_finished = true
		Direction.DOWN:
			if (position.y >= ((dest_grid.y * Map_Controller.GRID_CELL_SIZE_PX) + player_image_offset_px.y)):
				# AT DOWN DEST
				move_finished = true
		Direction.LEFT:
			if (position.x <= ((dest_grid.x * Map_Controller.GRID_CELL_SIZE_PX) + player_image_offset_px.x)):
				# AT LEFT DEST
				move_finished = true
		Direction.RIGHT:
			if (position.x >= ((dest_grid.x * Map_Controller.GRID_CELL_SIZE_PX) + player_image_offset_px.x)):
				# AT RIGHT DEST
				move_finished = true
		_:
			#TODO catch error for bad player dir
			print("ERROR: Bad direction on player check_move_complete()")

	# set player animation based on direction
	set_player_animation(player_direction, true)

	if (move_finished):
		player_moving = false
		# force player position to dest point
		position = Map_Controller.grid_to_point(dest_grid, player_image_offset_px)
		# update reference to player grid
		player_grid = Map_Controller.point_to_grid(position, player_image_offset_px)

	return

#DEBUG player debug print to console
func print_player_info() -> void:
	var player_info_report = {
		"player_moving": player_moving,
		"player_direction": Direction.keys()[player_direction],
		"player_world_coords": position,
		"dest_grid_coords": dest_grid,
		"player_grid_cords": player_grid,
		"tile_colliders_on_player_point": Map_Controller.check_grid_for_collider(player_grid)
	}
	print("player_info: " + str(player_info_report))
	return

# player action button, spacebar
func player_action_pressed() -> void:
	# get action coords / tilespot in front of player in direction facing
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

	# get tile info
	var tile_report = Map_Controller.get_world_tile_report(action_coords)
	print("action_button: " + str(tile_report))

	# set player as object on map-object-collection
	var _test = Map_Controller.set_object_at_coords(self, action_coords)
	# get object from map-object-collection
	var object = Map_Controller.get_object_at_coords(action_coords)
	print("returned object: ", object)

	return

# set player animation based on direction
func set_player_animation(dir: Direction, idle: bool) -> void:
	match dir:
		Direction.UP when idle:
			Player_Animation_Object.play("idle_up")
		Direction.UP when not idle:
			Player_Animation_Object.play("walk_up")
		Direction.DOWN when idle:
			Player_Animation_Object.play("idle_down")
		Direction.DOWN when not idle:
			Player_Animation_Object.play("walk_down")
		Direction.LEFT when idle:
			Player_Animation_Object.play("idle_side")
			Player_Animation_Object.flip_h = true
		Direction.LEFT when not idle:
			Player_Animation_Object.play("walk_side")
			Player_Animation_Object.flip_h = true
		Direction.RIGHT when idle:
			Player_Animation_Object.play("idle_side")
			Player_Animation_Object.flip_h = false
		Direction.RIGHT when not idle:
			Player_Animation_Object.play("walk_side")
			Player_Animation_Object.flip_h = false
	return
