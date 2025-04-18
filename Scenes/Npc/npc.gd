extends CharacterBody2D

class_name NPC_Class

@onready var map_controller = $"/root/MainScene/Overworld/MapController"
@onready var game_controller = get_tree().current_scene
var grid_coords
var battle_ready = true

func _ready() -> void:
	grid_coords = map_controller.point_to_grid(position)
	map_controller.set_object_at_coords(self, grid_coords)

func interact() -> void:
	#if battle_ready:
		#map_controller
	pass
 
func kill():
	map_controller.set_object_at_coords(null, grid_coords)
	queue_free()
