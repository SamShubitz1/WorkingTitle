extends Node2D

@export var DEBUG_PLAYER: bool = true

@onready var player: PlayerChar = $MyPlayer
@onready var map_controller = $"../MapController"
@onready var game_controller = get_tree().current_scene

signal player_position_updated(grid_position: Vector2i)

var dialog_mode: bool = false
var dialog_object: BaseObject

var weather = null

var default_player_pos = null

var pause_menu: Control

var initialized: bool = false

func _ready() -> void:
	player.grid_position = map_controller.point_to_grid(player.position)
	player.sprite.play("idle_down")
	add_pause_menu()
	
	#var state_success = load_state()
	#if state_success:
		#return
	#
	#var success = load_data()
	#if !success:
		#return
		#
	#player.position = map_controller.grid_to_point(player.initial_position_override) + player.sprite_offset
	#player.set_grid_position(player.initial_position_override)
	
func _process(delta: float) -> void:
	process_player_inputs() # gets input direction, checks for collision
	process_player_movement(delta) # moves player, checks for complete move

func process_player_movement(delta) -> void:
	if !player.is_moving:
		return
	player.position += player.speed * delta * player.current_direction
	check_move_complete()

# used for overworld movement and dialog/menu accept
func process_player_inputs() -> void:
	if player.is_moving || game_controller.is_loading:
		return
		
	if Input.is_action_just_pressed("ui_accept"):
		player_action_pressed()
		
	if Input.is_action_just_pressed("pause_menu"):
		if !dialog_mode:
			open_pause_menu()
		else:
			close_pause_menu()
		return
		
	if dialog_mode:
		return
		
	var input_direction = get_direction()
	
	if input_direction != Vector2i.ZERO:
		player.update_direction(input_direction)
		set_player_animation(player.current_direction, false)
		check_collision()
	else:
		set_player_animation(player.current_direction, true)
	
# used for dialog and movement
func get_direction() -> Vector2i:
	var input_direction: Vector2i
	if input_direction.y == 0:
		input_direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	if input_direction.x == 0:
		input_direction.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
		
	return input_direction

func _input(_e) -> void:
	if !dialog_mode:
		return
	var input_direction = get_direction()
	if input_direction != Vector2i.ZERO:
		dialog_object.update_selected_option(input_direction)

func check_collision() -> void:
	var dest_coords = player.get_grid_position() + player.current_direction

	var tile_collision_check = map_controller.check_for_collider(dest_coords)
	var object_collision_check = map_controller.get_object_at_coords(dest_coords)
	
	if tile_collision_check || object_collision_check:
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
		finish_move(dest_pos)

func finish_move(dest_pos: Vector2i) -> void:
	player.is_moving = false
	map_controller.remove_from_world_map([player.grid_position])
	player.position = dest_pos # force player player.position to dest point
	player.grid_position = map_controller.point_to_grid(player.position, player.sprite_offset)
	map_controller.set_object_at_coords(player, player.grid_position)
	
	GameState.current_time += 1
	if weather != null:
		weather.position = player.position
	#check_for_battle()
	check_for_camera_bounds()
	emit_signal("player_position_updated", player.grid_position)
	
func player_action_pressed() -> void:
	if dialog_mode:
		dialog_mode = dialog_object.select_option()
		return
	elif dialog_mode:
		return

	var action_coords = player.grid_position + player.current_direction
	var object = map_controller.get_object_at_coords(action_coords)
	var actioned_tile = map_controller.get_tile_at_coords(action_coords)
	#var tile_report = map_controller.get_world_tile_report(action_coords)
	
	if object == null && actioned_tile.is_empty(): #may want to check actioned_tile list members individually
		return
		
	interact(object)

func open_pause_menu():
	dialog_mode = true
	pause_menu.open()

func close_pause_menu():
	dialog_mode = false
	pause_menu.close()

func interact(object: Node):
	if object is BaseObject:
		if object.battle_ready:
			enter_battle_scene(object.battle_data)
		elif !object.dialog_tree.is_empty():
			set_player_animation(player.current_direction, true)
			dialog_mode = true
			dialog_object = object
			object.start_dialog()
			
	elif object is BaseDoor:
		player.position = object.spawn_position
		player.grid_position = map_controller.point_to_grid(player.position)
		map_controller.enter_door(object)
		check_for_camera_bounds()
		update_weather()
		
func update_weather() -> void:
	GameState.set_current_weather()
	if GameState.current_weather == GameState.Weather.RAINING:
		var weather_scene = load("res://Scenes/World/weather_visuals.tscn")
		weather = weather_scene.instantiate()
		game_controller.get_node("UI").add_child(weather)
		
	elif GameState.current_weather == GameState.Weather.CLEAR:
		if weather != null:
			weather.queue_free()
			weather = null

func check_for_battle() -> void:
	var enemy_areas = map_controller.get_updated_enemy_areas()
	for area in enemy_areas:
		if area.overlaps_area(player):
			player.increment_step_count()
			var random = randi_range(12, 28)
			if player.get_step_count() >= random:
				enter_battle_scene(area.battle_data) #placeholder logic?
		else:
			player.reset_step_count()
		
func check_for_camera_bounds():
	var bounds = map_controller.get_updated_camera_bounds()
	var limits = get_limits_with_overlap(bounds)
	
	player.set_camera_bounds(limits)

func get_limits_with_overlap(bounds: Array[Node]) -> Dictionary:
	var current_limits: Array
	for bound in bounds:
		var limits = bound.get_updated_limits()
		if overlaps(limits, player) || initialized == false:
			current_limits.append(limits)
	if current_limits.size() == 1:
		return current_limits[0]
	elif current_limits.size() > 1:
		var top_limit = null
		var left_limit = null
		var bottom_limit = null
		var right_limit = null
		
		for limit in current_limits:
			if top_limit == null:
				top_limit = limit.top
			else:
				top_limit = min(top_limit, limit.top)

			if left_limit == null:
				left_limit = limit.left
			else:
				left_limit = min(left_limit, limit.left)

			if bottom_limit == null:
				bottom_limit = limit.bottom
			else:
				bottom_limit = max(bottom_limit, limit.bottom)

			if right_limit == null:
				right_limit = limit.right
			else:
				right_limit = max(right_limit, limit.right)

		return {"top": top_limit, "left": left_limit, "bottom": bottom_limit, "right": right_limit}
	return {}

func overlaps(limits: Dictionary, player: Node) -> bool:
	if player.position.x > limits["left"] && player.position.x < limits["right"] && player.position.y > limits["top"] && player.position.y < limits["bottom"]:
		return true
	return false
	
func enter_battle_scene(battle_data: Dictionary) -> void:
	save_state()
	save_data()
	await game_controller.switch_to_scene(Data.Scenes.BATTLE, battle_data)

func set_player_animation(dir: Vector2i, idle: bool) -> void:
	match player.current_direction:
		Vector2i.UP when idle:
			player.sprite.play("idle_up")
		Vector2i.DOWN when idle:
			player.sprite.play("idle_down")
		Vector2i.LEFT when idle:
			player.sprite.play("idle_side")
			player.sprite.flip_h = true
		Vector2i.RIGHT when idle:
			player.sprite.play("idle_side")
			player.sprite.flip_h = false
		Vector2i.UP:
			player.sprite.play("walk_up")
		Vector2i.DOWN:
			player.sprite.play("walk_down")
		Vector2i.LEFT:
			player.sprite.play("walk_side")
			player.sprite.flip_h = true
		Vector2i.RIGHT:
			player.sprite.play("walk_side")
			player.sprite.flip_h = false

# set player player.position directly and update values
func set_loaded_position(pos: Vector2i, scope: String) -> void:
	match scope:
		"grid":
			var new_pos = map_controller.grid_to_point(pos, player.sprite_offset)
			player.position = new_pos
			player.grid_position = pos
			map_controller.remove_from_world_map(self)
			#map_controller.set_object_at_coords(self, pos)

func _exit_tree() -> void:
	print("calling _exit_tree()")

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
	#var result = 0
	#var PREFERENCE_FILE: String = "user://preferences.cfg"
	#var config = ConfigFile.new()
	#var err = config.load(PREFERENCE_FILE)
	#if err != OK:
		## file not found, creating new
		#print_debug("Creating user preference file...")
		#config.set_value("player", "grid_position", player.grid_position)
		#config.set_value("player", "direction", player.current_direction)
		#result = config.save(PREFERENCE_FILE)
	#else:
		## existing file found, updating
		#print_debug("Updating user preference file: " + str(player.grid_position))
		#config.set_value("player", "grid_position", player.grid_position)
		#config.set_value("player", "direction", player.current_direction)
		#result = config.save(PREFERENCE_FILE)
	var result = false
	return result

func save_state() -> void:
	GameState.player_direction = player.current_direction
	GameState.player_position = map_controller.grid_to_point(player.grid_position)
	GameState.current_map = map_controller.current_map.get_scene_file_path()

func load_state() -> bool:
	if GameState.player_position == Vector2.ZERO || GameState.player_direction == Vector2i.ZERO:
		return false
	player.position = GameState.player_position
	player.grid_position = map_controller.point_to_grid(player.position)
	player.current_direction = GameState.player_direction
	set_player_animation(player.current_direction, true)
	return true
	
func add_pause_menu() -> void:
	var pause_menu_scene = load("res://Scenes/StartMenu/start_menu.tscn")
	pause_menu = pause_menu_scene.instantiate()
	game_controller.get_node("UI").add_child(pause_menu)
	pause_menu.close()

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
	
func init(default_pos: Vector2) -> void:
	var bounds = map_controller.get_updated_camera_bounds()
	var camera_bounds = get_limits_with_overlap(bounds)
	player.set_camera_bounds(camera_bounds)
	update_weather()
	initialized = true
	
	var success = load_state()
	if success:
		return
	
	if default_pos:
		player.position = default_pos
	else:
		player.position = player.initial_position_override
		
	player.grid_position = map_controller.point_to_grid(player.position)
