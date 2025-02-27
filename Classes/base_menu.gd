extends Control

class_name BaseMenu

var cursor: BaseCursor
var menu: Node # reference to parent node to toggle visibility
var buttons: Array # array of menu buttons
var selected_button_index: int = 0 # track current selected button
var selected_button: Node # same as buttons[selected_button_index]

var initial_cursor_position: int

var scroll_size: int

var is_active: bool = false

func navigate_backward() -> void:
	if is_active:
		if selected_button_index == 0:
			selected_button_index += (scroll_size - 1)
			update_selected_button()
		else:
			selected_button_index -= 1
			update_selected_button()

func navigate_forward() -> void:
	if is_active:
		selected_button_index = (selected_button_index + 1) % scroll_size
		update_selected_button()

func activate() -> void:
	show_menu()
	is_active = true
	selected_button_index = 0
	update_selected_button()

func disactivate() -> void:
	is_active = false

func update_selected_button(index = null) -> void:
	if index:
		selected_button_index = index
	selected_button = buttons[selected_button_index]
	cursor.move_cursor(selected_button.position)

func init(menu: Node, menu_buttons: Array, menu_cursor: BaseCursor, initial_button_position = null) -> void:
	self.menu = menu
	self.buttons = menu_buttons
	self.cursor = menu_cursor
	hide_menu()
	selected_button = buttons[selected_button_index]
	if initial_button_position:
		selected_button.position = initial_button_position
	set_scroll_size()

func set_scroll_size(size: int = buttons.size()) -> void:
	scroll_size = size

func show_menu() -> void:
	menu.visible = true

func hide_menu() -> void:
	menu.visible = false

func get_selected_button_index() -> int:
	return selected_button_index

func get_selected_button() -> Button:
	return selected_button
