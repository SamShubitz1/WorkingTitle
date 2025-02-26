extends BaseMenuController

@onready var start_menu_cursor: BaseCursor = $Cursor
@onready var pokemon_card = $PokemonCard
@onready var pokemon_card_label = $PokemonCard/CardLabel
var main_menu = BaseMenu.new()
var pokedex_log = BaseLog.new()
var current_selected_button: Button

func _ready() -> void:
	initialize_menus()
	self.init(start_menu_cursor, menus)

func _input(_e) -> void:
	if not cursor.disabled:
		if Input.is_action_pressed("navigate_forward"):
			color_off()
			selected_menu.navigate_forward()
			update_pokedex_entry()
			color_on()

		elif Input.is_action_pressed("navigate_backward"):
			color_off()
			selected_menu.navigate_backward()
			update_pokedex_entry()
			color_on()
			
		if Input.is_action_just_pressed("ui_accept"):
			on_press_button()
		
		if Input.is_action_just_pressed("go_back"):
			if selected_menu != main_menu:
				selected_menu.hide_menu()
				go_back()
				pokemon_card.hide()
			
func on_press_button() -> void:
	if selected_menu == main_menu:
		var button_text = selected_menu.get_selected_button().text
		color_off() 
		match button_text:
			"Pokédex":
				update_selected_menu(Enums.MainMenuType.POKEDEX)
				color_on()
				update_pokedex_entry()
	elif selected_menu == pokedex_log:
		pokemon_card.visible = !pokemon_card.visible
				
func set_pokemon_card(entry) -> void:
	var pokemon_info = Enums.pokedex[entry]
	var text = str("Name: ", pokemon_info.name, "\n\n", "Types:", list_types(pokemon_info.type), "\n\n", "Description: ", pokemon_info.description)
	pokemon_card_label.text = text

func list_types(types: Array) -> String:
	var type_string = ""
	for type in types:
		type_string = str(type_string, " ", type)
	return type_string
	
func color_on() -> void:
	current_selected_button = selected_menu.get_selected_button()
	current_selected_button.modulate = Color(1, 1, 0)
	
func color_off() -> void:
	current_selected_button.modulate = Color(1, 1, 1)

func update_pokedex_entry() -> void:
	var entry = pokedex_log.get_current_entry()
	set_pokemon_card(entry)
	
func initialize_menus():
	var menu_buttons = self.get_node("MainMenu/Menu").get_children()
	var log_slots = self.get_node("PokedexLog/Menu").get_children()
	main_menu.init(self.get_node("MainMenu"), menu_buttons, start_menu_cursor)
	main_menu.activate()
	pokedex_log.init(self.get_node("PokedexLog"), log_slots, start_menu_cursor)
	pokedex_log.set_entries(["-","-","-"] + Enums.pokedex_entries)
	pokedex_log.hide_menu()
	current_selected_button = main_menu.get_selected_button()
	current_selected_button.modulate = Color(1, 1, 0)
	menus = [main_menu, pokedex_log]
	pokemon_card.hide()
