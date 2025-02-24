extends Control

class_name BaseMenuController

var cursor: BaseCursor
var menus: Array[BaseMenu] = []
var selected_menu: BaseMenu

func init(menu_cursor: BaseCursor, current_menus: Array) -> void:
	self.cursor = menu_cursor
	self.menus = current_menus
	selected_menu = menus[0]
	selected_menu.activate()

func update_selected_menu(selected_menu_index: int) -> void:
	selected_menu.disactivate()
	selected_menu = menus[selected_menu_index]
	cursor.set_menu_type(selected_menu_index)
	selected_menu.activate() # activating a menu makes it visible as well
