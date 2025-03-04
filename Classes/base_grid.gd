extends Node

class_name BaseGrid

var current_grid = {}

func set_object_at_grid_position(object: Character) -> void: # could eventually define non-char grid objects
	current_grid[object.grid_position] = object

func get_object_at_grid_position(position: Vector2i):
	var object = current_grid[position]
	if object:
		return object
