extends Control

@onready var cursor = $Cursor
@onready var options_menu = $Options.get_children().slice(1)
@onready var abilities_menu = $Abilities.get_children().slice(3)
@onready var description_panels = $Descriptions.get_children()
@onready var descriptions_menu = $Descriptions.get_children()
@onready var ability_description_label = description_panels[1].get_node("Label")

var character_abilities: Array = [
	{"name":"Rock", "description": "A rock based attack"},
	{"name": "Paper", "description": "A paper based attack"},
	{"name": "Scissors", "description": "A scissors based attack"}
	]

var selected_index: int = 0
var selected_button: Button

var menus: Array = []
var selected_menu_index: int = 0
var current_menu: Array

enum MenuType {
	OPTIONS,
	ABILITIES
}

func _ready() -> void:
	menus = [options_menu, abilities_menu]
	current_menu = menus[selected_menu_index]
	selected_button = current_menu[selected_index]
	populate_abilities_menu()
	cursor.move_cursor(Vector2i(0, 45))
	
func _input(_e) -> void:
	if Input.is_action_just_pressed("navigate_backward"):
		if selected_index == 0:
			selected_index += (current_menu.size() - 1)
			update_selected_button()
		else:
			selected_index = (selected_index - 1)
			update_selected_button()
			
	elif Input.is_action_just_pressed("navigate_forward"):
		selected_index = (selected_index + 1) % current_menu.size()
		update_selected_button()
		
	elif Input.is_action_just_pressed("ui_accept"):
		if selected_menu_index == 0:
			match selected_button.text:
				"1. Attack":
					on_attack_accept()
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
	selected_button = current_menu[selected_index]
	cursor.move_cursor(selected_button.position)
	
	if current_menu == abilities_menu:
		ability_description_label = description_panels[1].get_node("Label")
		if selected_index <= character_abilities.size() - 1:
			ability_description_label.text = character_abilities[selected_index].description
		else:
			ability_description_label.text = "???"

func on_attack_accept() -> void:
	selected_menu_index = (selected_menu_index + 1) % menus.size()
	current_menu = menus[selected_menu_index]
	cursor.set_menu_type(MenuType.ABILITIES)
	update_selected_button()
	
func populate_abilities_menu() -> void:
	for i in range(abilities_menu.size()):
		if i <= character_abilities.size() - 1:
			abilities_menu[i].text += str(i + 1) + ". " + character_abilities[i].name
		else:
			abilities_menu[i].text = "???"
