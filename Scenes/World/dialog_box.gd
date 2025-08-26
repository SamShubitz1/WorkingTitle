extends Control

class_name DialogBox

@onready var dialog_container = $DialogContainer
@onready var cover_anim_container = $DialogContainer/CoverAnimContainer
@onready var dialog = $DialogContainer/Dialog
@onready var options = $DialogContainer/Options.get_children()

enum NavDirection
{
	FORWARD,
	BACKWARD
}

signal close_box
signal open_box
signal rusty_powered # could be moved into a flag manager along with rest of flag logic

var option_index = 0
var current_options: Array
var current_tree: Dictionary
var anim_is_playing: bool

func _ready() -> void:
	emit_signal("open_box")

func _input(e) -> void:
	if Input.is_action_just_pressed("navigate_forward"):
		update_selected_option(NavDirection.FORWARD)
	elif Input.is_action_just_pressed("navigate_backward"):
		update_selected_option(NavDirection.BACKWARD)
	elif Input.is_action_just_pressed("ui_accept"):
		if anim_is_playing:
			kill_animations()
		else:
			select_option()

# pass the NPC or object's dialog tree, display default dialog
func set_tree(dialog_tree: Dictionary) -> void:
	current_tree = dialog_tree
	update_dialog("default")

# takes a dialog_tree key, sets new screen of dialog (text + options)
func update_dialog(next_branch: String) -> void:
	set_flags(next_branch)
	var current_dialog = current_tree.get(next_branch, current_tree["default"]) # default used as safe fallback
	handle_animation_covers(current_dialog.text)
	dialog.text = current_dialog.text
	current_options = current_dialog.options
	for i in range(options.size()):
		if i < current_options.size():
			options[i].show()
			options[i].text = current_options[i].name
			options[i].modulate = Color(1, 1, 1)
		else:
			options[i].hide()
			
	option_index = 0

# updates current selected option based on player input, changes colors
func update_selected_option(direction: NavDirection) -> void:
	if anim_is_playing:
		return
		
	options[option_index].modulate = Color(1, 1, 1)
	
	if direction == NavDirection.FORWARD:
		option_index = (option_index + 1) % current_options.size()
	elif direction == NavDirection.BACKWARD:
		if option_index == 0:
			option_index = current_options.size() - 1
		else:
			option_index -= 1
			
	options[option_index].modulate = Color(1, 1, 0)

# updates dialog or quits scene based on option, called on player action press
func select_option(): #this a string
	var next_dialog = current_options[option_index].get("next")
	if next_dialog == null:
		emit_signal("close_box")
		self.queue_free()
	else:
		update_dialog(next_dialog)
		
# this will eventually be generalized to iterate through region-specific dictionaries of dialog flags
func set_flags(branch: String) -> void:
	var object_name = current_tree.name
	if object_name == "tram_console" && branch == "trambutton01":
		PlayerFlags.flags["tram_console_button_pressed"] = true
	elif object_name == "eggcharger" && branch == "default":
		PlayerFlags.flags["egg_charger_greeted"] = true
	elif object_name == "newsboy" && branch == "leave01":
		PlayerFlags.flags["newsboy_leave_attempted"] = true
	elif object_name.contains("rusty") && branch == "powered01":
		PlayerFlags.flags[object_name + "_powered"] = true
		emit_signal("rusty_powered")

func handle_animation_covers(dialog: String) -> void:
	var number_of_lines = clamp(ceil(int(dialog.length() / 40)), 1, 4)
	build_text_covers(number_of_lines)
	play_text_covers()

func build_text_covers(number_of_lines: int):
	var offset = Vector2(0,50)
	for i in range(number_of_lines):
		var cover_anim_scene = load("res://Scenes/World/dialog_cover_animation.tscn")
		var cover_anim = cover_anim_scene.instantiate()
		cover_anim_container.add_child(cover_anim)
		cover_anim.position += offset
		offset.y += 50

func play_text_covers():
	anim_is_playing = true
	for anim in cover_anim_container.get_children():
		anim.play()
		await get_tree().create_timer(1.1).timeout
		if anim == null:
			#anim_is_playing = false
			break
		else:
			anim.queue_free()
	anim_is_playing = false
	options[option_index].modulate = Color(1, 1, 0)
	
func kill_animations():
	for anim in cover_anim_container.get_children():
		anim.queue_free()
	options[option_index].modulate = Color(1, 1, 0)
