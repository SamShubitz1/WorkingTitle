extends Area2D

class_name PlayerChar

@onready var sprite = $AnimatedSprite2D
@onready var player_camera = $OverworldCamera

@export var DEBUG_PLAYER: bool = true
@export var speed = 120
@export var sprite_offset = Vector2(16,16)
@export var initial_position_override = Vector2i(12,3)

var is_moving: bool = false
var grid_position = Vector2i(0,0)
var current_direction = Vector2i(0,1)
var step_count: int = 0

func increment_step_count() -> void:
	step_count += 1

func get_step_count() -> int:
	return step_count

func reset_step_count() -> void:
	step_count = 0

func get_grid_position() -> Vector2i:
	return grid_position

func set_grid_position(grid_pos: Vector2i) -> void:
	grid_position = grid_pos

func get_direction() -> Vector2i:
	return current_direction

func set_direction(dir: Vector2i) -> void:
	current_direction = dir

func get_is_moving() -> bool:
	return is_moving

func set_is_moving(value: bool) -> void:
	is_moving = value

func update_direction(input_direction: Vector2i) -> void:
	current_direction = input_direction
	is_moving = true

func set_camera_bounds(bounds: Dictionary):
	player_camera.limit_left = bounds["left"]
	player_camera.limit_right = bounds["right"]
	player_camera.limit_top = bounds["top"]
	player_camera.limit_bottom = bounds["bottom"]
	
