extends Control

@onready var cursor = $Cursor
@onready var options_menu = $MainMenu/Menu.get_children().slice(1)
@onready var abilities_menu = $AbilitiesMenu/Menu.get_children().slice(3)
@onready var char_name_label = $MainMenu/Menu/CharPanel/NameLabel
@onready var ability_description_label = $Descriptions/Labels/AbilityDescription
@onready var player_health = $MainMenu/Menu/CharPanel/Health
@onready var enemy_health = $"../Enemy/EnemyHealth"

var character_info: Dictionary = {"name": "Deeno", "max_health": 100, "abilities": [
	{"name":"Rock", "description": "A rock based attack"},
	{"name": "Paper", "description": "A paper based attack"},
	{"name": "Scissors", "description": "A scissors based attack"}
	]}
	
var enemy_info: Dictionary = {"name": "Norman", "max_health": 80, "abilities": ["Rock","Paper","Scissors"]}

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
	player_health.max_value = character_info["max_health"]
	enemy_health.max_value = enemy_info["max_health"]
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
		if selected_menu == options_menu:
			match selected_button.text:
				"1. Attack":
					on_select_abilities()
				"2. Move":
					pass
				"3. Items":
					pass
				"4. Status":
					pass
				"5. Retreat":
					pass
					
		elif selected_menu == abilities_menu:
			perform_attack(character_info.abilities[selected_button_index].name)
			
func update_selected_button() -> void:
	selected_button = selected_menu[selected_button_index]
	cursor.move_cursor(selected_button.position)
	
	if selected_menu == abilities_menu:
		if selected_button_index <= character_info.abilities.size() - 1:
			ability_description_label.text = character_info.abilities[selected_button_index].description
		else:
			ability_description_label.text = "???"

func on_select_abilities() -> void:
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
			
func perform_attack(player_attack: String) -> void:
	var enemy_attack = get_enemy_attack()
	if player_attack == "Rock":
		match enemy_attack:
			"Rock":
				pass
			"Paper":
				player_health.value -= 20
			"Scissors":
				enemy_health.value -= 20
	elif player_attack == "Paper":
		match enemy_attack:
			"Rock":
				enemy_health.value -= 20
			"Paper":
				pass
			"Scissors":
				player_health.value -= 20
	elif player_attack == "Scissors":
		match enemy_attack:
			"Rock":
				player_health.value -= 20
			"Paper":
				enemy_health.value -= 20
			"Scissors":
				pass
	check_death()
			
	
func get_enemy_attack() -> String:
	var attack_index = randi() % 3
	return enemy_info["abilities"][attack_index]
	
func check_death() -> void:
	if player_health.value <= 0 || enemy_health.value <= 0:
		get_tree().change_scene_to_file("res://Scenes/Main/mainscene.tscn") 
