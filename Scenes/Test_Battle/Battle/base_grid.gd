extends Node

class_name BaseGrid

var current_grid = {}
var grid_cells = []

func init(grid_size: Vector2i) -> void:
	grid_size
	build_grid_cells(grid_size)

func build_grid_cells(grid_size: Vector2i) -> void:
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			grid_cells.append(Vector2i(x, y))

func set_grid_position(position: Vector2i, object: Node) -> void:
	current_grid[position] = object

func get_object_at_grid_position(position: Vector2i):
	var object = current_grid[position]
	if object:
		return object

#battle_menu...
#it needs attack range
#it checks attack range, figures out grid_cells it will cover
#range could be a list of coordinates calculated off origin
#player can change origin - origin determines value of other coordinates
#
