extends Polygon2D

class_name BaseCursor

var disabled: bool = false

enum MenuType {
	OPTIONS,
	ABILITIES,
	ITEMS,
	TARGETS,
	LOG
}

var selected_menu_type: MenuType

func move_cursor(button_position: Vector2i) -> void:
	self.position = button_position

func set_menu_type(type: MenuType) -> void:
	selected_menu_type = type
	
func disable() -> void:
	disabled = true
	self.hide()

func enable() -> void:
	disabled = false
	self.show()
