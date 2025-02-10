extends Control

@onready var cursor = $Cursor
@onready var options_menu = $Main_Menu/Menu.get_children().slice(1)
@onready var abilities_menu = $Abilities_Menu/Menu.get_children().slice(3)
@onready var char_name_label = $Main_Menu/Menu/Name_Label
@onready var ability_description_label = $Descriptions/Labels/Ability_Description

var character_info: Dictionary = {"name": "Deeno", "abilities": [
	{"name":"Rock", "description": "A rock based attack"},
	{"name": "Paper", "description": "A paper based attack"},
	{"name": "Scissors", "description": "A scissors based attack"}
	]}

var selected_button_index: int = 0
var selected_button: Button

var menus: Array
var selected_menu_index: int = 0
var selected_menu: Array

var initial_cursor_position: Vector2i = Vector2i(0, 45)

enum MenuType {
	OPTIONS,
	ABILITIES
}

func _ready() -> void:
	menus = [options_menu, abilities_menu]
	selected_menu = menus[selected_menu_index]
	selected_button = selected_menu[selected_button_index]
	char_name_label.text = character_info.name
	populate_abilities_menu()
	cursor.move_cursor(initial_cursor_position)
	
func _input(_e) -> void:
	if Input.is_action_just_pressed("navigate_backward"):
		if selected_button_index == 0:
			selected_button_index += (selected_menu.size() - 1)
			update_selected_button()
		else:
			selected_button_index = (selected_button_index - 1)
			update_selected_button()
			
	elif Input.is_action_just_pressed("navigate_forward"):
		selected_button_index = (selected_button_index + 1) % selected_menu.size()
		update_selected_button()
		
	elif Input.is_action_just_pressed("go_back"):
		if selected_menu_index == 1:
			selected_menu_index -= 1
			selected_button_index = 0
			selected_menu = menus[selected_menu_index]
			cursor.set_menu_type(MenuType.OPTIONS)
			update_selected_button()
			ability_description_label.text = "Text"
		
	elif Input.is_action_just_pressed("ui_accept"):
		if selected_menu_index == 0:
			match selected_button.text:
				"1. Attack":
					on_select_attack()
				"2. Move":
					pass
				"3. Items":
					pass
				"4. Status":
					pass
				"5. Retreat":
					pass
					
		else:
			pass
			
func update_selected_button() -> void:
	selected_button = selected_menu[selected_button_index]
	cursor.move_cursor(selected_button.position)
	
	if selected_menu == abilities_menu:
		if selected_button_index <= character_info.abilities.size() - 1:
			ability_description_label.text = character_info.abilities[selected_button_index].description
		else:
			ability_description_label.text = "???"

func on_select_attack() -> void:
	selected_menu_index = (selected_menu_index + 1) % menus.size()
	selected_menu = menus[selected_menu_index]
	cursor.set_menu_type(MenuType.ABILITIES)
	update_selected_button()
	
func populate_abilities_menu() -> void:
	for i in range(abilities_menu.size()):
		if i <= character_info.abilities.size() - 1:
			abilities_menu[i].text += str(i + 1) + ". " + character_info.abilities[i].name
		else:
			abilities_menu[i].text = "???"
