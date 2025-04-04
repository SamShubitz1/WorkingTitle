class_name PlayerClass
extends CharacterBody2D

@onready var Animation_Object = $AnimatedSprite2D
@onready var Player_Camera = get_node("./OverworldCamera")

@export var DEBUG_PLAYER: bool = true
@export var speed = 75
@export var image_offset_px = Vector2i(8,8)
@export var Initial_Position_Override = Vector2i(12,3)

var is_moving: bool = false
var dest_grid = Vector2i(0,0)
var grid_position = Vector2i(0,0)

enum Direction {
	UP,
	DOWN,
	LEFT,
	RIGHT,
	NONE
}
#var current_direction: Direction = Direction.DOWN
var current_direction = 3

func get_grid_position() -> Vector2i:
	return grid_position

func set_grid_position(grid_pos: Vector2i) -> void:
	grid_position = grid_pos
	return

func get_direction() -> Direction:
	return current_direction

func set_direction(dir: Direction) -> void:
	current_direction = dir
	return

func get_is_moving() -> bool:
	return is_moving

func set_is_moving(value: bool) -> void:
	is_moving = value
	return
