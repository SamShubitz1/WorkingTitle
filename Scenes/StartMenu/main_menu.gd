extends BaseMenu

func init(menu: Node, menu_buttons: Array, menu_cursor: BaseCursor, initial_button_position = null) -> void:
	super.init(menu, menu_buttons, menu_cursor)
	cursor.hide()

func handle_animation_transition():
	var selected_button = buttons[selected_button_index]
	selected_button.play("default", -1)

func update_selected_button() -> void:
	var selected_button = buttons[selected_button_index]
	selected_button.play("default")
	
func navigate_backward(_e: InputEvent) -> void:
	if is_active:
		if selected_button_index == 0:
			handle_animation_transition()
			selected_button_index += (scroll_size - 1)
			update_selected_button()
		else:
			handle_animation_transition()
			selected_button_index -= 1
			update_selected_button()

func navigate_forward(_e: InputEvent) -> void:
	if is_active:
		handle_animation_transition()
		selected_button_index = (selected_button_index + 1) % scroll_size
		update_selected_button()
