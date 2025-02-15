extends Node2D

@onready var Player: PlayerClass = $MyPlayer
@onready var Map_Controller = $"../MapController"

@export var DEBUG_PLAYER: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# get updated reference for grid location
	Player.grid_position = Map_Controller.point_to_grid(Player.position)
	Player.Animation_Object.play("idle_down")
	
	# load player Player.position from preference file
	load_data()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#DEBUG hotkey for info print to console
	if (DEBUG_PLAYER and Input.is_action_just_pressed("testbutton")):
		print_player_info()

	process_player_movement(delta)
	process_player_inputs()
		# set_next_move(dir)
		# Player.is_moving
	pass


# translates input events to set_next_move function
#TODO possibly refactor for event / interrupt based input handling
func process_player_inputs() -> void:
	if Input.is_action_pressed("ui_up"):
		set_next_move(Player.Direction.UP)
	elif Input.is_action_pressed("ui_down"):
		set_next_move(Player.Direction.DOWN)
	elif Input.is_action_pressed("ui_left"):
		set_next_move(Player.Direction.LEFT)
	elif Input.is_action_pressed("ui_right"):
		set_next_move(Player.Direction.RIGHT)
	elif Input.is_action_just_pressed("ui_accept"):
		player_action_pressed()
	return # end process_player_inputs()

# set all values before process_player_movement() operates on incoming move command
func set_next_move(dir: int) -> void:
	if Player.is_moving:
		# already moving, exit this function
		return

	# set player direction
	Player.current_direction = dir

	# sets destination grid
	match dir:
		Player.Direction.UP:
			Player.dest_grid.y = Player.grid_position.y - 1
		Player.Direction.DOWN:
			Player.dest_grid.y = Player.grid_position.y + 1
		Player.Direction.LEFT:
			Player.dest_grid.x = Player.grid_position.x - 1
		Player.Direction.RIGHT:
			Player.dest_grid.x = Player.grid_position.x + 1
		_:
			#TODO catch error for bad input value on dir
			print_debug("ERROR: Bad direction input given to player on set_next_move(dir)")

	# set player animation based on direction
	set_player_animation(Player.current_direction, false)

	# check if next move is valid
	var tile_collision_check = Map_Controller.check_grid_for_collider(Player.dest_grid)
	var object_collision_check = Map_Controller.get_object_at_coords(Player.dest_grid)
	if (tile_collision_check or object_collision_check):
		# collider found, reset move state and values, and exit early
		if (DEBUG_PLAYER): print_debug("Player collision at cell: " + str(Player.dest_grid))
		var collided_object = Map_Controller.get_object_at_coords(Player.dest_grid)
		if (DEBUG_PLAYER): print_debug("Collided with: " + str(collided_object))
		Player.is_moving = false
		Player.dest_grid = Player.grid_position
		check_move_complete()
		return # collider found, return early to stop moving

	# set player as moving, do not process new movements until this move completes
	Player.is_moving = true
	return

# move player
func process_player_movement(_delta) -> void:
	if not Player.is_moving:
		# no move command to operate on, exit
		return

	# move player object by Player.speed value
	match Player.current_direction:
		Player.Direction.UP:
			Player.position.y -= Player.speed * _delta
		Player.Direction.DOWN:
			Player.position.y += Player.speed * _delta
		Player.Direction.LEFT:
			Player.position.x -= Player.speed * _delta
		Player.Direction.RIGHT:
			Player.position.x += Player.speed * _delta
		_:
			#TODO catch error for bad player dir
			print_debug("ERROR: Bad direction on player process_player_movement()")

	# update player grid coords reference
	Player.grid_position = Map_Controller.point_to_grid(Player.position, Player.image_offset_px)
	# check if at destination
	check_move_complete()
	return # end process_player_movement()

# check if player is at destination
func check_move_complete() -> void:
	var move_finished: bool = false # local/temp var for tracking move state

	match Player.current_direction:
		Player.Direction.UP:
			if (Player.position.y <= ((Player.dest_grid.y * Map_Controller.GRID_CELL_SIZE_PX) + Player.image_offset_px.y)):
				# AT UP DEST
				move_finished = true
		Player.Direction.DOWN:
			if (Player.position.y >= ((Player.dest_grid.y * Map_Controller.GRID_CELL_SIZE_PX) + Player.image_offset_px.y)):
				# AT DOWN DEST
				move_finished = true
		Player.Direction.LEFT:
			if (Player.position.x <= ((Player.dest_grid.x * Map_Controller.GRID_CELL_SIZE_PX) + Player.image_offset_px.x)):
				# AT LEFT DEST
				move_finished = true
		Player.Direction.RIGHT:
			if (Player.position.x >= ((Player.dest_grid.x * Map_Controller.GRID_CELL_SIZE_PX) + Player.image_offset_px.x)):
				# AT RIGHT DEST
				move_finished = true
		_:
			#TODO catch error for bad player dir
			print_debug("ERROR: Bad direction on player check_move_complete()")

	if (move_finished):
		# set player idle animation based on direction
		#print_debug("setting player to idle")
		set_player_animation(Player.current_direction, true)

	if (move_finished):
		Player.is_moving = false
		# force player Player.position to dest point
		Player.position = Map_Controller.grid_to_point(Player.dest_grid, Player.image_offset_px)
		# update reference to player grid
		Player.grid_position = Map_Controller.point_to_grid(Player.position, Player.image_offset_px)

	return


# player action button, spacebar
func player_action_pressed() -> void:
	# get action coords / tilespot in front of player in direction facing
	var action_coords = Player.grid_position
	match Player.current_direction:
		Player.Direction.UP:
			action_coords.y -= 1
		Player.Direction.DOWN:
			action_coords.y += 1
		Player.Direction.LEFT:
			action_coords.x -= 1
		Player.Direction.RIGHT:
			action_coords.x += 1

	

	# get object from map-object-collection
	var object = Map_Controller.get_object_at_coords(action_coords)
	var actioned_tile = Map_Controller.get_tile_at_grid_coords(action_coords)
	if(object == null and actioned_tile == null):
		return
	
	if(object != null):
		if (DEBUG_PLAYER): print_action_object_report(object)
		if (object.battle_ready):
			enter_battle_scene()
		object.kill()
	elif(actioned_tile != null):
		# get tile info
		var tile_report = Map_Controller.get_world_tile_report(action_coords)
		print_debug("action_button: " + str(tile_report))
	return


# begin battle scene
func enter_battle_scene() -> void:
	save_data()
	get_tree().change_scene_to_file("res://Scenes/Battle/battle.tscn")
	return

# set player animation based on direction
func set_player_animation(dir: int, idle: bool) -> void:
	match dir:
		Player.Direction.UP when idle:
			Player.Animation_Object.play("idle_up")
		Player.Direction.UP when not idle:
			Player.Animation_Object.play("walk_up")
		Player.Direction.DOWN when idle:
			Player.Animation_Object.play("idle_down")
		Player.Direction.DOWN when not idle:
			Player.Animation_Object.play("walk_down")
		Player.Direction.LEFT when idle:
			Player.Animation_Object.play("idle_side")
			Player.Animation_Object.flip_h = true
		Player.Direction.LEFT when not idle:
			Player.Animation_Object.play("walk_side")
			Player.Animation_Object.flip_h = true
		Player.Direction.RIGHT when idle:
			Player.Animation_Object.play("idle_side")
			Player.Animation_Object.flip_h = false
		Player.Direction.RIGHT when not idle:
			Player.Animation_Object.play("walk_side")
			Player.Animation_Object.flip_h = false
	return

# set player Player.position directly and update values
func set_player_position(pos: Vector2i, scope: String) -> void:
	match scope:
		"grid":
			var newPos = Map_Controller.grid_to_point(pos, Player.image_offset_px)
			Player.position = newPos
			Player.grid_position = pos
			Player.dest_grid = pos
			Map_Controller.remove_object_from_map_collection(self)
			#Map_Controller.set_object_at_coords(self, pos)
	return


#DEBUG player debug print to console
func print_player_info() -> void:
	var player_info_report = {
		"Player.is_moving": Player.is_moving,
		"Player.current_direction": Player.Direction.keys()[Player.current_direction],
		"player_world_coords": Player.position,
		"Player.dest_grid_coords": Player.dest_grid,
		"Player.grid_position_cords": Player.grid_position,
		"tile_colliders_on_player_point": Map_Controller.check_grid_for_collider(Player.grid_position)
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
		config.set_value("player", "grid_position", Player.grid_position)
		result = config.save(PREFERENCE_FILE)
	else:
		# existing file found, updating
		print_debug("Updating user preference file: " + str(Player.grid_position))
		config.set_value("player", "grid_position", Player.grid_position)
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
		config.set_value("player", "grid_position", Player.grid_position)
		_result = config.save(PREFERENCE_FILE)
	else:
		# existing file found, reading it
		var loaded_grid_position = config.get_value("player", "grid_position")
		set_player_position(loaded_grid_position, "grid")
		print_debug("loaded config: " + str(Player.grid_position))

	return true