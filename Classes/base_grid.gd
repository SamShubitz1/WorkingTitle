extends Node

class_name BaseGrid

var current_grid = {}

func set_object_at_grid_position(position: Vector2i, object: Node) -> void:
	current_grid[position] = object

func get_object_at_grid_position(position: Vector2i):
	var object = current_grid[position]
	if object:
		return object
