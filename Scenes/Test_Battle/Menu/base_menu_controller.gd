#extends Control
#
#class_name BaseMenuController
#
#var cursor: BaseCursor
#var menus: Array[BaseMenu] = []
#var selected_menu: BaseMenu
#
#func init(menu_cursor: BaseCursor, current_menus: Array) -> void:
	#self.cursor = menu_cursor
	#self.menus = current_menus
	#selected_menu = menus[0]
	#selected_menu.activate()
