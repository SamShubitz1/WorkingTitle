extends Node2D

@onready var player: PlayerClass = $MyPlayer
@onready var map_controller = $"../MapController"
@onready var game_controller = get_tree().current_scene
@onready var player_camera = player.player_camera

@export var DEBUG_PLAYER: bool = true

var can_action = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	can_action = false
	# get updated reference for grid location
	player.grid_position = map_controller.point_to_grid(player.position)
	player.animation_object.play("idle_down")

	# load player player.position from preference file
	load_data()
	player.position = map_controller.grid_to_point(player.initial_position_override)
	player.set_grid_position(player.initial_position_override)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#DEBUG hotkey for info print to console
	#if (DEBUG_PLAYER and Input.is_action_just_pressed("testbutton")):
		#print_player_info()

	process_player_movement(delta)
	process_player_inputs()
		# set_next_move(dir)
		# player.is_moving
	if (not can_action):
		can_action = true
	pass


# translates input events to set_next_move function
#TODO possibly refactor for event / interrupt based input handling
func process_player_inputs() -> void:
	if Input.is_action_pressed("ui_up"):
		set_next_move(player.Direction.UP)
	elif Input.is_action_pressed("ui_down"):
		set_next_move(player.Direction.DOWN)
	elif Input.is_action_pressed("ui_left"):
		set_next_move(player.Direction.LEFT)
	elif Input.is_action_pressed("ui_right"):
		set_next_move(player.Direction.RIGHT)
	elif Input.is_action_just_pressed("ui_accept"):
		player_action_pressed()
	return # end process_player_inputs()

# set all values before process_player_movement() operates on incoming move command
func set_next_move(dir: int) -> void:
	if player.is_moving:
		# already moving, exit this function
		return

	# set player direction
	player.current_direction = dir

	# sets destination grid
	match dir:
		player.Direction.UP:
			player.dest_grid.y = player.grid_position.y - 1
		player.Direction.DOWN:
			player.dest_grid.y = player.grid_position.y + 1
		player.Direction.LEFT:
			player.dest_grid.x = player.grid_position.x - 1
		player.Direction.RIGHT:
			player.dest_grid.x = player.grid_position.x + 1
		_:
			#TODO catch error for bad input value on dir
			print_debug("ERROR: Bad direction input given to player on set_next_move(dir)")

	# set player animation based on direction
	set_player_animation(player.current_direction, false)

	# check if next move is valid
	var tile_collision_check = map_controller.check_grid_for_collider(player.dest_grid)
	var object_collision_check = map_controller.get_object_at_coords(player.dest_grid)
	if (tile_collision_check or object_collision_check):
		# collider found, reset move state and values, and exit early
		if (DEBUG_PLAYER): print_debug("player collision at cell: " + str(player.dest_grid))
		var collided_object = map_controller.get_object_at_coords(player.dest_grid)
		if (DEBUG_PLAYER): print_debug("Collided with: " + str(collided_object))
		player.is_moving = false
		player.dest_grid = player.grid_position
		check_move_complete()
		return # collider found, return early to stop moving

	# set player as moving, do not process new movements until this move completes
	player.is_moving = true
	return

# move player
func process_player_movement(_delta) -> void:
	if not player.is_moving:
		# no move command to operate on, exit
		return

	# move player object by player.speed value
	match player.current_direction:
		player.Direction.UP:
			player.position.y -= player.speed * _delta
		player.Direction.DOWN:
			player.position.y += player.speed * _delta
		player.Direction.LEFT:
			player.position.x -= player.speed * _delta
		player.Direction.RIGHT:
			player.position.x += player.speed * _delta
		_:
			#TODO catch error for bad player dir
			print_debug("ERROR: Bad direction on player process_player_movement()")

	# update player grid coords reference
	player.grid_position = map_controller.point_to_grid(player.position, player.image_offset_px)
	# check if at destination
	check_move_complete()
	return # end process_player_movement()

# check if player is at destination
func check_move_complete() -> void:
	var move_finished: bool = false # local/temp var for tracking move state

	match player.current_direction:
		player.Direction.UP:
			if (player.position.y <= ((player.dest_grid.y * map_controller.GRID_CELL_SIZE_PX) + player.image_offset_px.y)):
				# AT UP DEST
				move_finished = true
		player.Direction.DOWN:
			if (player.position.y >= ((player.dest_grid.y * map_controller.GRID_CELL_SIZE_PX) + player.image_offset_px.y)):
				# AT DOWN DEST
				move_finished = true
		player.Direction.LEFT:
			if (player.position.x <= ((player.dest_grid.x * map_controller.GRID_CELL_SIZE_PX) + player.image_offset_px.x)):
				# AT LEFT DEST
				move_finished = true
		player.Direction.RIGHT:
			if (player.position.x >= ((player.dest_grid.x * map_controller.GRID_CELL_SIZE_PX) + player.image_offset_px.x)):
				# AT RIGHT DEST
				move_finished = true
		_:
			#TODO catch error for bad player dir
			print_debug("ERROR: Bad direction on player check_move_complete()")

	if (move_finished):
		# set player idle animation based on direction
		#print_debug("setting player to idle")
		set_player_animation(player.current_direction, true)

	if (move_finished):
		player.is_moving = false
		# force player player.position to dest point
		player.position = map_controller.grid_to_point(player.dest_grid, player.image_offset_px)
		# update reference to player grid
		player.grid_position = map_controller.point_to_grid(player.position, player.image_offset_px)

	return


# player action button, spacebar
func player_action_pressed() -> void:
	if (not can_action):
		return
	# get action coords / tilespot in front of player in direction facing
	var action_coords = player.grid_position
	match player.current_direction:
		player.Direction.UP:
			action_coords.y -= 1
		player.Direction.DOWN:
			action_coords.y += 1
		player.Direction.LEFT:
			action_coords.x -= 1
		player.Direction.RIGHT:
			action_coords.x += 1

	print("player obj id: " + str(self))
	# get tile info
	var tile_report = map_controller.get_world_tile_report(action_coords)
	print_debug("action_button: " + str(tile_report))

	# get object from map-object-collection
	var object = map_controller.get_object_at_coords(action_coords)
	var actioned_tile = map_controller.get_tile_at_grid_coords(action_coords)
	if(object == null and actioned_tile == null):
		return

	if(object != null):
		if (object is NPC_Class):
			if (DEBUG_PLAYER): print_action_object_report(object)
			if (object.battle_ready):
				enter_battle_scene(object)
		elif (object is BaseDoor):
			print("playerController - Door_Destination: " + str(object.Door_Destination))
			game_controller.enter_door(object)
		else:
			print("unknown object")
	return


# begin battle scene
func enter_battle_scene(object: Node) -> void:
	save_data()
	game_controller.switch_to_battle_scene()
	return

# set player animation based on direction
func set_player_animation(dir: int, idle: bool) -> void:
	match dir:
		player.Direction.UP when idle:
			player.animation_object.play("idle_up")
		player.Direction.UP when not idle:
			player.animation_object.play("walk_up")
		player.Direction.DOWN when idle:
			player.animation_object.play("idle_down")
		player.Direction.DOWN when not idle:
			player.animation_object.play("walk_down")
		player.Direction.LEFT when idle:
			player.animation_object.play("idle_side")
			player.animation_object.flip_h = true
		player.Direction.LEFT when not idle:
			player.animation_object.play("walk_side")
			player.animation_object.flip_h = true
		player.Direction.RIGHT when idle:
			player.animation_object.play("idle_side")
			player.animation_object.flip_h = false
		player.Direction.RIGHT when not idle:
			player.animation_object.play("walk_side")
			player.animation_object.flip_h = false
	return

# set player player.position directly and update values
func set_player_position(pos: Vector2i, scope: String) -> void:
	match scope:
		"grid":
			var newPos = map_controller.grid_to_point(pos, player.image_offset_px)
			player.position = newPos
			player.grid_position = pos
			player.dest_grid = pos
			map_controller.remove_object_from_map_collection(self)
			#map_controller.set_object_at_coords(self, pos)
	return

func _exit_tree() -> void:
	print("player_controller is about to die")
	return

# set player direction
func set_player_direction(dir: int, idle: bool = true) -> void:
	player.current_direction = dir
	print("dir: " + str(dir))
	print("player dir: " + str(player.current_direction))
	match dir:
		player.Direction.UP when idle:
			player.animation_object.play("idle_up")
		player.Direction.DOWN when idle:
			player.animation_object.play("idle_down")
		player.Direction.LEFT when idle:
			player.animation_object.play("idle_side")
			player.animation_object.flip_h = true
		player.Direction.RIGHT when idle:
			player.animation_object.play("idle_side")
			player.animation_object.flip_h = false
	return

#DEBUG player debug print to console
func print_player_info() -> void:
	var player_info_report = {
		"player.is_moving": player.is_moving,
		"player.current_direction": player.Direction.keys()[player.current_direction],
		"player_world_coords": player.position,
		"player.dest_grid_coords": player.dest_grid,
		"player.grid_position_cords": player.grid_position,
		"tile_colliders_on_player_point": map_controller.check_grid_for_collider(player.grid_position)
	}
	print_debug("player_info: " + str(player_info_report))
	return

#DEBUG print actioned object report
func print_action_object_report(object) -> void:
	var object_report = {
		"object name": str(object),
		"type": typeof(object),
		"grid_coords": object.grid_coords
	}
	print_debug("action_object_report: " + str(object_report))
	return

# save player data to disk
func save_data() -> bool:
	var result = 0
	var PREFERENCE_FILE : String = "user://preferences.cfg"
	var config = ConfigFile.new()
	var err = config.load(PREFERENCE_FILE)
	if err != OK:
		# file not found, creating new
		print_debug("Creating user preference file...")
		config.set_value("player", "grid_position", player.grid_position)
		config.set_value("player", "direction", player.current_direction)
		result = config.save(PREFERENCE_FILE)
	else:
		# existing file found, updating
		print_debug("Updating user preference file: " + str(player.grid_position))
		config.set_value("player", "grid_position", player.grid_position)
		config.set_value("player", "direction", player.current_direction)
		result = config.save(PREFERENCE_FILE)

	return result

# load player data from disk
func load_data() -> bool:
	var _result = 0
	var PREFERENCE_FILE : String = "user://preferences.cfg"
	var config = ConfigFile.new()
	var err = config.load(PREFERENCE_FILE)
	if err != OK:
		# file not found, creating new
		print_debug("Creating user preference file...")
		config.set_value("player", "grid_position", player.grid_position)
		config.set_value("player", "direction", player.current_direction)
		_result = config.save(PREFERENCE_FILE)
	else:
		# existing file found, reading it
		var loaded_grid_position = config.get_value("player", "grid_position")
		var loaded_direction = config.get_value("player", "direction")
		set_player_position(loaded_grid_position, "grid")
		set_player_direction(loaded_direction)
		print_debug("loaded config: " + str(player.grid_position))

	return true
