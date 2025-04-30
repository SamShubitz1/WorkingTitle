extends BaseNPC

var dialog = {
			"default": {
				"text": "A broken egg charger machine. Someone has attempted to crack it for a free juice-up.",
				"options": [
					{"name": "Investigate", "next": "investigate"},
					{"name": "Leave", "next": null}]
					},
			"investigate": {
				"text": "This egg is crazy.",
				"options": [
					{"name": "Take egg", "next": "take egg"},
					{"name": "Investigate (2)", "next": "investigate2"},
					{"name": "Interrogate", "next": "interrogate"},
					{"name": "Leave", "next": null}]
					},
			"investigate2": {
				"text": "It's not that crazy actually.",
				"options": [
					{"name": "Take egg", "next": "take egg"},
					{"name": "Interrogate", "next": "interrogate"},
					{"name": "Leave", "next": null}]
					},
			"interrogate": {
				"text": "The egg is silent.",
				"options": [
					{"name": "Investigate", "next": "investigate"},
					{"name": "Interrogate (2)", "next": "interrogate2"},
					{"name": "Leave", "next": null}]
					},
			"interrogate2": {
				"text": "The egg remains stoic.",
				"options": [
					{"name": "Take egg", "next": "take egg"},
					{"name": "Leave", "next": null}]
					},
			"take egg": {
				"text": "You took the egg.",
				"options": [
					{"name": "Leave", "next": null}]
					},
			}

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	dialog_tree = dialog
	var neighbor_coords = Vector2i(grid_coords.x - 1, grid_coords.y)
	map_controller.set_object_at_coords(self, neighbor_coords)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
