extends TextureRect

var options_offset = Vector2i(110, 11)
var items_offset = Vector2i(120, 11)
var abilities_offset = Vector2i(490, 21)

var disabled: bool = false

enum MenuType {
	OPTIONS,
	ABILITIES,
	ITEMS
}

var selected_menu_type: MenuType = MenuType.OPTIONS

func move_cursor(button_position: Vector2i) -> void:
		if selected_menu_type == MenuType.OPTIONS:
			self.position = button_position + options_offset
		elif selected_menu_type == MenuType.ABILITIES:
			self.position = button_position + abilities_offset
		elif selected_menu_type == MenuType.ITEMS:
			self.position = button_position + items_offset

func set_menu_type(type: MenuType) -> void:
	selected_menu_type = type
	
func disable() -> void:
	disabled = true
	self.hide()

func enable() -> void:
	disabled = false
	self.show()
	
