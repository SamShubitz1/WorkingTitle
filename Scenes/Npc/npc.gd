extends Node2D

class_name BaseNPC

@onready var map_controller = $"/root/MainScene/Overworld/MapController"
@onready var game_controller = get_tree().current_scene
@export var sprite_offset = Vector2(16,16)

var grid_coords
var battle_ready = false
var dialog_tree: Dictionary = {}

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

# overworld object class
# grid coords
# handle dialog

# door class
# change tile map

# npc class
# movement logic
# battle logic
