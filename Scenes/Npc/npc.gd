extends CharacterBody2D

@onready var Map_Controller = $"/root/MainScene/Overworld/MapController"
@onready var Game_Controller = get_tree().current_scene
var grid_coords
var battle_ready = true

func _ready() -> void:
	grid_coords = Map_Controller.point_to_grid(position)
	# set player as object on map-object-collection
	var _test = Map_Controller.set_object_at_coords(self, grid_coords)
	#Map_Controller.add_grid_collider(grid_coords)
	return

func kill():
	Map_Controller.set_object_at_coords(null, grid_coords)
	queue_free()
