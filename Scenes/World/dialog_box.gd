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
func update_dialog(next_branch: String) -> void:
	set_flags(next_branch)
	var current_dialog = current_tree[next_branch]
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
func select_option(): #this a string
	var next_dialog = current_options[option_index].get("next")
	return next_dialog
		
# this will eventually be generalized to iterate through region-specific dictionaries of dialog flags
func set_flags(branch: String) -> void:
	var object_name = current_tree.name
	if object_name == "tram_console" && branch == "trambutton01":
		PlayerFlags.flags["tram_console_button_pressed"] = true
	if object_name == "eggcharger" && branch == "default":
		PlayerFlags.flags["egg_charger_greeted"] = true
	if object_name == "newsboy" && branch == "leave01":
		PlayerFlags.flags["newsboy_leave_attempted"] = true
