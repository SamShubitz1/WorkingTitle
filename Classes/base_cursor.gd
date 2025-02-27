extends Polygon2D

class_name BaseCursor

var disabled: bool = false
var selected_menu_type: Enums.MenuType

func move_cursor(button_position: Vector2i) -> void:
	if not disabled:
		self.position = button_position

func set_menu_type(type: Enums.MenuType) -> void:
	selected_menu_type = type
	
func disable() -> void:
	disabled = true
	self.hide()

func enable() -> void:
	disabled = false
	self.show()
