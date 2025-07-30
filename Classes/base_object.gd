extends Node2D

class_name BaseObject

@onready var map_controller = $"/root/MainScene/Overworld/MapController"
@onready var game_controller = get_tree().current_scene
@onready var sprite = get_child(0)

@export var battle_ready: bool = false
@export var neighbor_coords: Array

var grid_coords: Vector2i
var dialog_tree: Dictionary
var dialog_box: DialogBox 

func _ready() -> void:
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
		elif variant.type == "next_variant": #for replacing a tree option
			for branch in dialog_tree.keys().slice(2):
				for option in dialog_tree[branch].options:
					if option.name == variant.option_name:
						option.next = variant.next
		elif variant.type == "default_variant": #for replacing default
			dialog_tree["default"] = dialog_tree[variant.branch]

func update_tree() -> Dictionary:
	resolve_options()
	return dialog_tree
 
func start_dialog() -> void:
	var updated_tree = update_tree()
	var dialog_scene = load("res://Scenes/World/dialog_box.tscn")
	dialog_box = dialog_scene.instantiate()
	game_controller.get_node("UI").add_child(dialog_box)
	dialog_box.set_tree(updated_tree)
	#dialog_box.position = self.position ####NEEDS FIX
#dialog_box.update_selected_option(input_direction)

func update_selected_option(input_direction: Vector2i):
	if dialog_box != null:
		dialog_box.update_selected_option(input_direction)

func select_option():
	if dialog_box == null:
		return false
		
	var selected_dialog = dialog_box.select_option()
	if selected_dialog == null:
		dialog_box.queue_free()
		return false
	else:
		dialog_box.update_dialog(selected_dialog)
		return true

func kill() -> void:
	map_controller.set_object_at_coords(null, grid_coords)
	queue_free()
