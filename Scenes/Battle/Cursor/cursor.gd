extends TextureRect

enum MenuType {
	OPTIONS,
	ABILITIES
}

var current_menu_type = MenuType.OPTIONS
var options_offset = Vector2i(110, 11)
var abilities_offset = Vector2i(490, 21)

#Enum types become their index?
func move_cursor(position: Vector2i) -> void:
	if current_menu_type == 0:
		self.position = position + options_offset
	elif current_menu_type == 1:
		self.position = position + abilities_offset

func set_menu_type(type: MenuType):
	current_menu_type = type
