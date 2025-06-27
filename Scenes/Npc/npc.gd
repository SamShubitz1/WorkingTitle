extends Node2D

class_name BaseObject

@onready var map_controller = $"/root/MainScene/Overworld/MapController"
@onready var game_controller = get_tree().current_scene

@export var object_name: String
@export var battle_ready: bool = false
@export var neighbor_coords: Array[Vector2i]

var grid_coords: Vector2i
var dialog_tree: Dictionary

func _ready() -> void:
	#var current_tree = GameData.dialog.get(object_name)
	#if current_tree:
		#dialog_tree = current_tree
	
	grid_coords = map_controller.point_to_grid(position)
	map_controller.set_object_at_coords(self, grid_coords)
	
	for coords in neighbor_coords:
		var neighbor = grid_coords + coords
		map_controller.set_object_at_coords(self, neighbor)
			
func resolve_options() -> void:
	for variant in dialog_tree.variants:
		var flag = PlayerFlags.flags.get(variant.flag)
		if !flag:
			continue
			
		if variant.type == "options_variant": #should be an enum really
			dialog_tree[variant.branch].options = variant.options
		elif variant.type == "next_variant":
			for branch in dialog_tree.keys().slice(2):
				for option in dialog_tree[branch].options:
					if option.name == variant.option_name:
						option.next = variant.next

func update_tree() -> Dictionary:
	resolve_options()
	return dialog_tree
 
func kill() -> void:
	map_controller.set_object_at_coords(null, grid_coords)
	queue_free()
