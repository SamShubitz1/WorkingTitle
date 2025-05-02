extends Node2D

class_name BaseNPC

@onready var map_controller = $"/root/MainScene/Overworld/MapController"
@onready var game_controller = get_tree().current_scene
@export var char_name: String
@export var neighbor_coords: Array[Vector2i]

var grid_coords: Vector2i
var battle_ready: bool = false
var dialog_tree: Dictionary
var dialog_variants: Array

func _ready() -> void:
	var current_tree = GameData.dialog.get(char_name)
	if current_tree:
		dialog_tree = current_tree
	
	grid_coords = map_controller.point_to_grid(position)
	map_controller.set_object_at_coords(self, grid_coords)
	
	for coords in neighbor_coords:
		var neighbor = grid_coords + coords
		map_controller.set_object_at_coords(self, neighbor)
			
func resolve_options() -> void:
	for variant in GameData.dialog[char_name].variants:
		var flag = PlayerFlags.flags.get(variant.flag)
		if flag:
			dialog_tree[variant.branch].options = variant.options

func update_tree() -> Dictionary:
	resolve_options()
	return dialog_tree
 
func kill():
	map_controller.set_object_at_coords(null, grid_coords)
	queue_free()
