extends Node2D
class_name BaseRoom
@export var default_pos: Vector2



@onready var camera_bounds = $CameraBoundContainer.get_children()

func get_camera_bounds() -> Array[Node]:
	return camera_bounds
