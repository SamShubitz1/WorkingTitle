extends BaseCursor

var main_offset = Vector2i(850, 80)

func move_cursor(button_position: Vector2i) -> void:
	match selected_menu_type:
		Enums.MainMenuType.MAIN:
			self.position = button_position + main_offset
		#Enums.MainMenuType.POKEDEX:
			#self.hide()
