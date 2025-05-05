############### REPOSITORY ###############

extends BaseNPC

var dialog = {
			"default": {
				"text": "(There is a slot where battery cells can be inserted. The call button will send your deposit through a tube that leads to the reactor.)",
				"options": [
					{"name": "Insert Batteries[10]", "next": "repository01"},
					{"name": "Leave", "next": null}]
					},
			"repository01": {
				"text": "(The machine prints out a ticket.)[br][br]Thank you for your contribution",
				"options": [
					{"name": "Leave", "next": null}]
					},
			}

func get_flags():
	return []

func _ready():
	super._ready()
	dialog_tree = dialog
	var neighbor_coords = Vector2i(grid_coords.x, grid_coords.y)
	map_controller.set_object_at_coords(self, neighbor_coords)
