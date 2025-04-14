extends CharacterBody2D

class_name NPC_Class

@onready var map_controller = $"/root/MainScene/Overworld/MapController"
@onready var game_controller = get_tree().current_scene
var grid_coords
var battle_ready = true

func _ready() -> void:
	grid_coords = map_controller.point_to_grid(position)
	# set player as object on map-object-collection
	var _test = map_controller.set_object_at_coords(self, grid_coords)
	#Map_Controller.add_grid_collider(grid_coords)
	return

func kill():
	map_controller.set_object_at_coords(null, grid_coords)
	queue_free()
