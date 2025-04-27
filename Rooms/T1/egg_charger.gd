extends NPC_Class


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	var neighbor_coords = Vector2i(grid_coords.x - 1, grid_coords.y)
	map_controller.set_object_at_coords(self, neighbor_coords)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
