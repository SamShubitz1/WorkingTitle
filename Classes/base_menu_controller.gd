extends Control

class_name BaseMenuController

var cursor: BaseCursor
var menus: Array[BaseMenu] = []
var selected_menu_index: int
var selected_menu: BaseMenu
var menu_history: Array

func init(menu_cursor: BaseCursor, current_menus: Array) -> void:
	self.cursor = menu_cursor
	self.menus = current_menus
	selected_menu = menus[Enums.MainMenuType.MAIN]
	selected_menu.activate()

func update_selected_menu(index: int) -> void:
	if index != selected_menu_index:
		selected_menu_index = index
		selected_menu.disactivate()
		menu_history.append(menus.find(selected_menu))
		selected_menu = menus[selected_menu_index]
		cursor.set_menu_type(selected_menu_index)
		selected_menu.activate()

func go_back() -> void:
	if not menu_history.is_empty():
		var prev_menu_index = menu_history.pop_back()
		update_selected_menu(prev_menu_index)
