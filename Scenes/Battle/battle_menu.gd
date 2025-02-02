extends Control

@onready var cursor = $Cursor
@onready var options_list = $Options.get_children().slice(1)
@onready var abilities_list = $Abilities.get_children()
@onready var descriptions_list = $Descriptions.get_children()

var selected_index: int = 0
var selected_button: Button = null
#var current_menu?

func _ready() -> void:
	update_selected_button()
	cursor.move_cursor(Vector2i(0, 45))
	
func _input(e) -> void:
	if Input.is_action_just_pressed("navigate_up"):
		if selected_index == 0:
			selected_index += (options_list.size() - 1)
			update_selected_button()
		else:
			selected_index = (selected_index - 1)
			update_selected_button()
	elif Input.is_action_just_pressed("navigate_down"):
		selected_index = (selected_index + 1) % options_list.size()
		update_selected_button()
	
func update_selected_button() -> void:
	selected_button = options_list[selected_index]
	cursor.move_cursor(selected_button.position)
