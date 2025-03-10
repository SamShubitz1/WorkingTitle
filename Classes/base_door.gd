extends Node

class_name BaseDoor

@export var Door_Destination: String = ""
@export var Collider: bool = false

var grid_coords
var ready_delay = 0
var Map_Controller

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (ready_delay == 3):
		_deferred_ready()
		ready_delay += 1
	elif(ready_delay < 3):
		ready_delay += 1
	pass

# run sometime after ready
func _deferred_ready():
	Map_Controller = GameData.GlobalMapControllerRef
	print("door deferred ready: " + str(Map_Controller))
	# get updated reference for grid location
	grid_coords = Map_Controller.point_to_grid(self.position)
	Map_Controller.set_object_at_coords(self, grid_coords)
	
	return
