extends TextureRect

var selected_menu_type: MenuType = MenuType.OPTIONS
var options_offset = Vector2i(110, 11)
var abilities_offset = Vector2i(490, 21)

enum MenuType {
	OPTIONS,
	ABILITIES
}

#Enum types become their index?
func move_cursor(button_position: Vector2i) -> void:
	if selected_menu_type == 0:
		self.position = button_position + options_offset
	elif selected_menu_type == 1:
		self.position = button_position + abilities_offset

func set_menu_type(type: MenuType):
	selected_menu_type = type
