extends Node2D

@onready var player: PlayerClass = $MyPlayer
@onready var map_controller = $"../MapController"
@onready var game_controller = get_tree().current_scene
@onready var player_camera = player.player_camera

@export var DEBUG_PLAYER: bool = true

func _ready() -> void:
	player.grid_position = map_controller.point_to_grid(player.position)
	player.animation_object.play("idle_down")

	var success = load_data()
	if !success:
		return
		
	player.position = map_controller.grid_to_point(player.initial_position_override) + player.sprite_offset
	player.set_grid_position(player.initial_position_override)

func _process(delta: float) -> void:
	process_player_inputs()
	process_player_movement(delta)

func process_player_movement(delta) -> void:
	if !player.is_moving:
		return
	player.position += player.speed * delta * player.current_direction
	check_move_complete()
	
func process_player_inputs() -> void:
	if player.is_moving:
		return
		
	var input_direction: Vector2i
	
	if input_direction.y == 0:
		input_direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	if input_direction.x == 0:
		input_direction.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
		
	if Input.is_action_just_pressed("ui_accept"):
		player_action_pressed()
	
	if input_direction != Vector2i.ZERO:
		player.is_moving = true
		player.current_direction = input_direction
		check_collision(input_direction)

func check_collision(direction: Vector2i) -> void:
	var dest_coords = player.grid_position + direction
	set_player_animation(player.current_direction, false)

	var tile_collision_check = map_controller.check_grid_for_collider(dest_coords)
	var object_collision_check = map_controller.get_object_at_coords(dest_coords)
	
	if tile_collision_check || object_collision_check:
		set_player_animation(player.current_direction, true)
		player.is_moving = false

func check_move_complete():
	var dest_pos = map_controller.grid_to_point(player.grid_position + player.current_direction) + player.sprite_offset
	
	var move_finished: bool
	var difference = dest_pos - player.position
	match player.current_direction:
		Vector2i.DOWN:
			move_finished = difference.y <= 0
		Vector2i.UP:
			move_finished = difference.y >= 0
		Vector2i.RIGHT:
			move_finished = difference.x <= 0
		Vector2i.LEFT:
			move_finished = difference.x >= 0
		_:
			print("Invalid input direction in player controller")
 
	if move_finished:
		player.is_moving = false
		set_player_animation(player.current_direction, true)
		player.position = dest_pos # force player player.position to dest point
		player.grid_position = map_controller.point_to_grid(player.position, player.sprite_offset) # update reference to player grid

# player action button, spacebar
func player_action_pressed() -> void:
	if player.is_moving:
		return
	# get action coords / tilespot in front of player in direction facing
	var action_coords = player.grid_position + player.current_direction

	print("player obj id: " + str(self))
	var tile_report = map_controller.get_world_tile_report(action_coords)
	print_debug("action_button: " + str(tile_report))

	# get object from map-object-collection
	var object = map_controller.get_object_at_coords(action_coords)
	var actioned_tile = map_controller.get_tile_at_grid_coords(action_coords)
	if (object == null and actioned_tile == null):
		return

	if (object != null):
		if (object is NPC_Class):
			if (DEBUG_PLAYER): print_action_object_report(object)
			if (object.battle_ready):
				enter_battle_scene(object)
		elif (object is BaseDoor):
			print("playerController - Door_Destination: " + str(object.Door_Destination))
			game_controller.enter_door(object)
		else:
			print("unknown object")

func enter_battle_scene(object: Node) -> void:
	save_data()
	game_controller.switch_to_battle_scene()

# set player animation based on direction
func set_player_animation(dir: Vector2i, idle: bool) -> void:
	if idle:
		if dir.y == -1:
			player.animation_object.play("idle_up")
		elif dir.y == 1:
			player.animation_object.play("idle_down")
		elif dir.x == -1:
			player.animation_object.play("idle_side")
			player.animation_object.flip_h = true
		elif dir.x == 1:
			player.animation_object.play("idle_side")
			player.animation_object.flip_h = false
	elif !idle:
		if dir.y == -1:
			player.animation_object.play("walk_up")
		elif dir.y == 1:
			player.animation_object.play("walk_down")
		elif dir.x == -1:
			player.animation_object.play("walk_side")
			player.animation_object.flip_h = true
		elif dir.x == 1:
			player.animation_object.play("walk_side")
			player.animation_object.flip_h = false

# set player player.position directly and update values
func set_loaded_position(pos: Vector2i, scope: String) -> void:
	match scope:
		"grid":
			var newPos = map_controller.grid_to_point(pos, player.sprite_offset)
			player.position = newPos
			player.grid_position = pos
			map_controller.remove_object_from_map_collection(self)
			#map_controller.set_object_at_coords(self, pos)

func _exit_tree() -> void:
	print("player_controller is about to die")

#DEBUG player debug print to console
func print_player_info() -> void:
	var player_info_report = {
		"player.is_moving": player.is_moving,
		"player.current_direction": player.current_direction,
		"player_world_coords": player.position,
		"player.dest_grid_coords": player.dest_grid,
		"player.grid_position_cords": player.grid_position,
		"tile_colliders_on_player_point": map_controller.check_grid_for_collider(player.grid_position)
	}
	print_debug("player_info: " + str(player_info_report))

#DEBUG print actioned object report
func print_action_object_report(object) -> void:
	var object_report = {
		"object name": str(object),
		"type": typeof(object),
		"grid_coords": object.grid_coords
	}
	print_debug("action_object_report: " + str(object_report))

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
		set_loaded_position(loaded_grid_position, "grid")
		set_player_animation(loaded_direction, true)
		print_debug("loaded config: " + str(player.grid_position))

	return true
