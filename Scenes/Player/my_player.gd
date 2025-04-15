class_name PlayerClass
extends CharacterBody2D

@onready var animation_object = $AnimatedSprite2D
@onready var player_camera = $OverworldCamera

@export var DEBUG_PLAYER: bool = true
@export var speed = 60
@export var sprite_offset = Vector2(8,8)
@export var initial_position_override = Vector2i(12,3)

var is_moving: bool = false

var grid_position = Vector2i(0,0)

var current_direction = Vector2i(0,1)

func get_grid_position() -> Vector2i:
	return grid_position

func set_grid_position(grid_pos: Vector2i) -> void:
	grid_position = grid_pos
	return

func get_direction() -> Vector2i:
	return current_direction

func set_direction(dir: Vector2i) -> void:
	current_direction = dir
	return

func get_is_moving() -> bool:
	return is_moving

func set_is_moving(value: bool) -> void:
	is_moving = value
	return
