extends Node

class_name BaseDoor

@export var door_destination: String
#@export var collider: bool = false
@onready var map_controller = $"/root/MainScene/Overworld/MapController"

var grid_coords: Vector2i

func _ready() -> void:
	grid_coords = map_controller.point_to_grid(self.position)
	map_controller.set_object_at_coords(self, grid_coords)

#func init(destination_res_path):
	#door_destination = destination_res_path
