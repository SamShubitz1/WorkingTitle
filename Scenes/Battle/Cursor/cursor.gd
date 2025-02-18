extends Polygon2D

var options_offset = Vector2i(95, 520)
var items_offset = Vector2i(500, 535)
var abilities_offset = Vector2i(480, 535)
var targets_offset = Vector2i(130, -10)
var log_offset = Vector2i(6, 5)

var disabled: bool = false

enum MenuType {
	OPTIONS,
	ABILITIES,
	ITEMS,
	TARGETS,
	LOG
}

var selected_menu_type: MenuType = MenuType.OPTIONS

func move_cursor(button_position: Vector2i) -> void:
	match selected_menu_type:
		MenuType.OPTIONS:
			self.color = Color(1, 1, 1)
			self.position = button_position + options_offset
		MenuType.ABILITIES:
			self.color = Color(1, 1, 1)
			self.position = button_position + abilities_offset
		MenuType.ITEMS:
			self.position = button_position + items_offset
		MenuType.TARGETS:
			self.color = Color(1, 0, 0)
			self.position = button_position + targets_offset
		MenuType.LOG:
			self.color = Color(1, 1, 1)
			self.position = button_position + log_offset
			
			

func set_menu_type(type: MenuType) -> void:
	selected_menu_type = type
	
func disable() -> void:
	disabled = true
	self.hide()

func enable() -> void:
	disabled = false
	self.show()
