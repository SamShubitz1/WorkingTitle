extends BaseCursor

var options_offset = Vector2i(95, 520)
var items_offset = Vector2i(500, 535)
var abilities_offset = Vector2i(480, 535)
var targets_offset = Vector2i(130, -10)

func move_cursor(button_position: Vector2i) -> void:
	match selected_menu_type:
		GameData.BattleMenuType.OPTIONS:
			self.color = Color(1, 1, 1)
			self.position = button_position + options_offset
		GameData.BattleMenuType.ABILITIES:
			self.color = Color(1, 1, 1)
			self.position = button_position + abilities_offset
		GameData.BattleMenuType.ITEMS:
			self.position = button_position + items_offset
		GameData.BattleMenuType.TARGETS:
			self.color = Color(1, 0, 0)
			self.position = button_position + targets_offset
