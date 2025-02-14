extends Control

@onready var cursor = $Cursor
@onready var battle_controller = $"../BattleController"
@onready var options_menu = $MainMenu/Menu.get_children().slice(1)
@onready var abilities_menu = $AbilitiesMenu/Menu.get_children().slice(3)
@onready var char_name_label = $MainMenu/Menu/CharPanel/NameLabel
@onready var ability_description_label = $Descriptions/Labels/AbilityDescription

var character_info: Dictionary = {"name": "Deeno", "max_health": 100, "abilities": [
	{"name":"Rock", "description": "A rock based attack"},
	{"name": "Paper", "description": "A paper based attack"},
	{"name": "Scissors", "description": "A scissors based attack"}
	]}

enum EventType {
	DIALOG,
	ATTACK,
	ITEM
}

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
	update_ui()
	update_menus()
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
		if battle_controller.event_queue.size() > 0:
			print(battle_controller.event_queue)
			battle_controller.increment_queue()
			
		elif selected_menu == options_menu:
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
					on_select_retreat()
					
		elif selected_menu == abilities_menu:
			if selected_button_index < character_info.abilities.size():
				var attack = character_info.abilities[selected_button_index].name
				battle_controller.on_attack(attack)
			
func update_selected_button() -> void:
	selected_button = selected_menu[selected_button_index]
	cursor.move_cursor(selected_button.position)
	
	if selected_menu == abilities_menu:
		if selected_button_index < character_info.abilities.size():
			ability_description_label.text = character_info.abilities[selected_button_index].description
		else:
			ability_description_label.text = "???"

func on_select_attack() -> void:
	selected_menu_index = (selected_menu_index + 1) % menus.size()
	selected_menu = menus[selected_menu_index]
	cursor.set_menu_type(MenuType.ABILITIES)
	update_selected_button()
	
func on_select_retreat() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main/mainscene.tscn")
	
func update_ui() -> void:
	char_name_label.text = character_info.name
	
	for i in range(abilities_menu.size()):
		if i < character_info.abilities.size():
			abilities_menu[i].text += str(i + 1) + ". " + character_info.abilities[i].name
		else:
			abilities_menu[i].text = "???"
	
func update_menus() -> void:
	menus = [options_menu, abilities_menu]
	selected_menu = menus[selected_menu_index]
	selected_button = selected_menu[selected_button_index]
			
