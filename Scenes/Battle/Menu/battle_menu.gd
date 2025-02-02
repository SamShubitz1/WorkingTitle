extends Control

enum MenuType {
	OPTIONS,
	ABILITIES
}

@onready var cursor = $Cursor
@onready var options_menu = $Options.get_children().slice(1)
@onready var abilities_menu = $Abilities.get_children().slice(3)
@onready var descriptions_menu = $Descriptions.get_children()

var character_abilities: Array = ["Rock", "Paper", "Scissors"]

var selected_index: int = 0
var selected_button: Button

var menus: Array = []
var selected_menu_index: int = 0
var current_menu: Array

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
	
func populate_abilities_menu() -> void:
	for i in range(abilities_menu.size()):
		if i <= character_abilities.size() - 1:
			abilities_menu[i].text = str(i + 1) + ". " + character_abilities[i]
		else:
			abilities_menu[i].text = "???"

func on_attack_accept() -> void:
	selected_menu_index = (selected_menu_index + 1) % menus.size()
	current_menu = menus[selected_menu_index]
	cursor.set_menu_type(MenuType.ABILITIES)
	update_selected_button()
