extends CanvasLayer

class_name DialogBox

@onready var dialog = $DialogContainer/Dialog
@onready var options = $DialogContainer/Options.get_children()

func set_dialog(next_dialog: Dictionary) -> void:
	dialog.text = next_dialog.text
	var dialog_options = next_dialog.options.keys()
	for i in range(dialog_options.size()):
		options[i].show()
		options[i].text = dialog_options[i]
