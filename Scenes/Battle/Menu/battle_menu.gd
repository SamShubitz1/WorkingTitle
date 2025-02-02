extends Control

@onready var cursor = $Cursor
@onready var options_list = $Options.get_children().slice(1)
@onready var abilities_list = $Abilities.get_children().slice(3)
@onready var descriptions_list = $Descriptions.get_children()

var character_abilities: Array = ["Rock", "Paper", "Scissors"]

var selected_index: int = 0
var selected_button: Button = null

var menus: Array = [options_list, abilities_list]
var selected_menu_index: int = 0
var current_menu = null

func _ready() -> void:
	populate_abilities_menu()
	update_selected_button()
	cursor.move_cursor(Vector2i(0, 45))
	
func _input(e) -> void:
	if Input.is_action_just_pressed("navigate_up"):
		if selected_index == 0:
			selected_index += (options_list.size() - 1)
			update_selected_button()
		else:
			selected_index = (selected_index - 1)
			update_selected_button()
	elif Input.is_action_just_pressed("navigate_down"):
		selected_index = (selected_index + 1) % options_list.size()
		update_selected_button()
	elif Input.is_action_just_pressed("ui_accept"):
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
			
func update_selected_button() -> void:
	current_menu = menus[selected_menu_index]
	if current_menu:
		selected_button = current_menu[selected_index]
	else:
		selected_button = options_list[selected_index]
	cursor.move_cursor(selected_button.position)
	
func populate_abilities_menu() -> void:
	for i in range(abilities_list.size()):
		if i <= 2:
			abilities_list[i].text = str(i + 1) + ". " + character_abilities[i]
		else:
			abilities_list[i].text = "???"

func on_attack_accept() -> void:
	selected_menu_index = (selected_menu_index + 1) % menus.size()
	current_menu = menus[selected_menu_index]
	cursor.move_cursor(selected_button.position)
	print(current_menu, selected_button)
