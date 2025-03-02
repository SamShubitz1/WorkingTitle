extends Node2D

@export var Door_Destination = "Demo_Room_2"

#@onready var Game_Controller = get_tree().current_scene
#@onready var Map_Controller = $"/MainScene/Overworld/MapController"
#@onready var Map_Controller = get_tree().get_nodes_in_group("MyControllers")
var grid_position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Map_Controller = Game_Controller.get_map_controller()
	#print("door get mapController: " + str(Map_Controller))
	
	# get updated reference for grid location
	#grid_position = Map_Controller.point_to_grid(position)
	#Map_Controller.set_object_at_coords(self, grid_position)
	#var foo = get_tree().get_nodes_in_group("MyControllers")
	#print("nodegroup: " + str(foo))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
