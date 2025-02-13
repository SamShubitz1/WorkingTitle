extends TextureRect

var options_offset = Vector2i(110, 11)
var abilities_offset = Vector2i(490, 21)

enum MenuType {
	OPTIONS,
	ABILITIES
}

var selected_menu_type: MenuType = MenuType.OPTIONS

func move_cursor(button_position: Vector2i) -> void:
	if selected_menu_type == MenuType.OPTIONS:
		self.position = button_position + options_offset
	elif selected_menu_type == MenuType.ABILITIES:
		self.position = button_position + abilities_offset

func set_menu_type(type: MenuType) -> void:
	selected_menu_type = type
