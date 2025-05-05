extends Control

class_name DialogBox

@onready var dialog_container = $DialogContainer
@onready var dialog = $DialogContainer/Dialog
@onready var options = $DialogContainer/Options.get_children()

var option_index = 0
var current_options: Array
var current_tree: Dictionary

# pass the NPC or object's dialog tree, display default dialog
func set_tree(dialog_tree: Dictionary) -> void:
	dialog_container.position -= Vector2(180, 100)
	current_tree = dialog_tree
	update_dialog("default")

# takes a dialog_tree key, sets new screen of dialog (text + options)
func update_dialog(next_dialog: String) -> void:
	var current_dialog = current_tree[next_dialog]
	dialog.text = "[center]" + current_dialog.text
	current_options = current_dialog.options
	for i in range(options.size()):
		if i < current_options.size():
			options[i].show()
			options[i].text = current_options[i].name
			options[i].modulate = Color(1, 1, 1)
		else:
			options[i].hide()
			
	option_index = 0
	options[option_index].modulate = Color(1, 1, 0)

# updates current selected option based on player input, changes colors
func update_selected_option(direction: Vector2i) -> void:
	options[option_index].modulate = Color(1, 1, 1)
	
	if direction == Vector2i.RIGHT || direction == Vector2i.DOWN:
		option_index = (option_index + 1) % current_options.size()
	elif direction == Vector2i.LEFT || direction == Vector2i.UP:
		if option_index == 0:
			option_index = current_options.size() - 1
		else:
			option_index -= 1
			
	options[option_index].modulate = Color(1, 1, 0)

# updates dialog or quits scene based on option, called on player action press
func select_option() -> bool:
	if options[option_index].text == "Leave":
		self.queue_free()
		return true
	else:
		set_flags(current_options[option_index].next)
		update_dialog(current_options[option_index].next)
		return false
		
func set_flags(branch) -> void:
	var object_name = current_tree.name
	if object_name == "tram_console" && branch == "trambutton01":
		PlayerFlags.flags["tram_console_button_pressed"] = true
