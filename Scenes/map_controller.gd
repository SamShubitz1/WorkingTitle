extends Node2D

@export var GRID_CELL_SIZE_PX: int = 16

var world_map_array = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_object_at_coordinates(position: Vector2i) -> Node:
	var object = world_map_array[position]
	if object:
		return object
	return null

func set_object_at_coordinates(object: Node, position: Vector2i) -> bool:
	world_map_array[position] = object
	return true
