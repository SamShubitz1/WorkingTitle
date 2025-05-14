extends Control

@onready var start_menu_cursor: BaseCursor = $Cursor
@onready var pokemon_card = $PokemonCard
@onready var pokemon_card_label = $PokemonCard/CardLabel
@onready var main_menu = $MainMenu

var menus: Array[BaseMenu] = []
var selected_menu_index: int
var selected_menu: BaseMenu
var menu_history: Array

var pokedex_log = BaseLog.new()
var current_selected_button: Node
var cursor: BaseCursor

func init(menu_cursor: BaseCursor, current_menus: Array) -> void:
	self.cursor = menu_cursor
	self.menus = current_menus
	selected_menu = menus[GameData.MainMenuType.MAIN]
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

func _ready() -> void:
	initialize_menus()
	self.init(start_menu_cursor, menus)



func _input(_e) -> void:
	if not cursor.disabled:
		if Input.is_action_pressed("navigate_forward"):
			selected_menu.navigate_forward(_e)
			update_pokedex_entry()

		elif Input.is_action_pressed("navigate_backward"):
			selected_menu.navigate_backward(_e)
			update_pokedex_entry()
			
		if Input.is_action_just_pressed("ui_accept"):
			on_press_button()
		
		if Input.is_action_just_pressed("go_back"):
			if selected_menu != main_menu:
				selected_menu.hide_menu()
				go_back()
				pokemon_card.hide()
				
func on_press_button() -> void:
	return
	#if selected_menu == main_menu:
		#var button_text = selected_menu.get_selected_button().text
		#match button_text:
			#"Pokédex":
				#update_selected_menu(GameData.MainMenuType.POKEDEX)
				#update_pokedex_entry()
	#elif selected_menu == pokedex_log:
		#pokemon_card.visible = !pokemon_card.visible
				
func set_pokemon_card(entry) -> void:
	var pokemon_info = GameData.pokedex[entry]
	var text = str("Name: ", pokemon_info.name, "\n\n", "Types:", list_types(pokemon_info.type), "\n\n", "Description: ", pokemon_info.description)
	pokemon_card_label.text = text

func list_types(types: Array) -> String:
	var type_string = ""
	for type in types:
		type_string = str(type_string, " ", type)
	return type_string
	
func update_pokedex_entry() -> void:
	var entry = pokedex_log.get_current_entry()
	set_pokemon_card(entry)
	
func initialize_menus():
	var menu_buttons = self.get_node("MainMenu/Menu").get_children()
	var log_slots = self.get_node("PokedexLog/Menu").get_children()
	main_menu.init(self.get_node("MainMenu"), menu_buttons, start_menu_cursor)
	main_menu.activate()
	pokedex_log.init(self.get_node("PokedexLog"), log_slots, start_menu_cursor, null, ["-","-","-"] + GameData.pokedex_entries)
	pokedex_log.hide_menu()
	current_selected_button = main_menu.get_selected_button()
	menus = [main_menu, pokedex_log]
	pokemon_card.hide()
