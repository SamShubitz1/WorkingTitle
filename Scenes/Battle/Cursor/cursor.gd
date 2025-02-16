extends TextureRect

var options_offset = Vector2i(110, 11)
var items_offset = Vector2i(120, 11)
var abilities_offset = Vector2i(490, 21)
var target_offset = Vector2i(400, -500)

var disabled: bool = false

enum MenuType {
	OPTIONS,
	ABILITIES,
	ITEMS,
	TARGET
}

var selected_menu_type: MenuType = MenuType.OPTIONS

func move_cursor(button_position: Vector2i) -> void:
	match selected_menu_type:
		MenuType.OPTIONS:
			self.position = button_position + options_offset
		MenuType.ABILITIES:
			self.position = button_position + abilities_offset
		MenuType.ITEMS:
			self.position = button_position + items_offset
		MenuType.TARGET:
			self.position = button_position + target_offset

func set_menu_type(type: MenuType) -> void:
	selected_menu_type = type
	
func disable() -> void:
	disabled = true
	self.hide()

func enable() -> void:
	disabled = false
	self.show()
