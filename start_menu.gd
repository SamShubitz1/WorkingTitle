extends BaseMenuController

@onready var start_menu_cursor: BaseCursor = $Cursor
var main_menu = BaseMenu.new()
var pokedex_log = BaseLog.new()
var entries = ["poke", "e", "min", "pok", "e", "dex", "entries"]
var current_selected_button: Button

func _ready() -> void:
	initialize_menus()
	self.init(start_menu_cursor, menus)

func _input(_e) -> void:
	if not cursor.disabled:
		if Input.is_action_just_pressed("navigate_forward"):
			color_off()
			selected_menu.navigate_forward()
			color_on()

		elif Input.is_action_just_pressed("navigate_backward"):
			color_off()
			selected_menu.navigate_backward()
			color_on()
			
		if Input.is_action_just_pressed(("ui_accept")):
			update_selected_menu(1)
		
		if Input.is_action_just_pressed(("go_back")):
			selected_menu.hide_menu()
			update_selected_menu(0)
	
func color_on() -> void:
	current_selected_button = main_menu.get_selected_button()
	current_selected_button.modulate = Color(1, 1, 0)
	
func color_off() -> void:
	current_selected_button.modulate = Color(1, 1, 1)
	
func initialize_menus():
	var menu_buttons = self.get_node("MainMenu/Menu").get_children()
	var log_slots = self.get_node("PokedexLog/Menu").get_children()
	main_menu.init(self.get_node("MainMenu"), menu_buttons, start_menu_cursor)
	main_menu.activate()
	pokedex_log.init(self.get_node("PokedexLog"), log_slots, start_menu_cursor)
	pokedex_log.set_entries(entries)
	pokedex_log.hide_menu()
	current_selected_button = main_menu.get_selected_button()
	current_selected_button.modulate = Color(1, 1, 0)
	menus = [main_menu, pokedex_log]
	
