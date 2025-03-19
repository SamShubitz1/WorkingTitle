extends Node

class_name BaseGrid

var current_grid = {}

func set_object_at_grid_position(object: Node) -> void: # could eventually define non-char grid objects
	current_grid[object.grid_position] = object

func get_object_at_grid_position(position: Vector2i):
	var object = current_grid[position]
	if object:
		return object

func update_grid_object(object: Node, next_position: Vector2i) -> void:
	current_grid.erase(object.grid_position)
	object.set_grid_position(next_position)
	current_grid[next_position] = object
	
func populate_grid(objects: Array) -> void:
	for object in objects:
		set_object_at_grid_position(object)
