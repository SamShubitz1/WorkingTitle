extends Control

@onready var cursor = $Cursor
@onready var battle_controller = $"../BattleController"
@onready var options_node = $MainMenu
@onready var options_menu = $MainMenu/Menu.get_children().slice(1)
@onready var abilities_menu = $AbilitiesMenu/Menu.get_children().slice(3)
@onready var items_node = $ItemsMenu
@onready var items_menu = $ItemsMenu/Menu.get_children().slice(1)
@onready var char_name_label = $MainMenu/Menu/CharPanel/NameLabel
@onready var description_label = $Descriptions/Labels/AbilityDescription
@onready var character_info = $"../Player"

var selected_button_index: int = 0
var selected_button: Button

var menus: Array
var selected_menu_index: int = 0
var selected_menu: Array

var initial_cursor_position: Vector2 = Vector2(0, 45)

#using process_frame seems to help avoid race issues w/ updating cursor position
func _ready() -> void:
	items_node.hide()
	update_ui()
	update_menus()
	await get_tree().process_frame
	cursor.move_cursor(initial_cursor_position)
	
func _input(_e) -> void:
	if not cursor.disabled:
		if Input.is_action_just_pressed("navigate_backward"):
			navigate_backward()
				
		elif Input.is_action_just_pressed("navigate_forward"):
			navigate_forward()
			
		elif Input.is_action_just_pressed("go_back"):
			go_back()
			
	if Input.is_action_just_pressed("ui_accept"):
		if not battle_controller.event_queue.is_empty():
			battle_controller.increment_queue()
			if battle_controller.event_queue.size() == 0:
				cursor.enable()
		
		elif selected_menu == options_menu:
			on_select_option()
					
		elif selected_menu == abilities_menu:
			on_select_ability()
				
		elif selected_menu == items_menu:
			on_select_item()
 
#using process_frame seems to help avoid race issues w/ updating cursor position
func update_selected_button() -> void:
	selected_button = selected_menu[selected_button_index]
	await get_tree().process_frame
	cursor.move_cursor(selected_button.position)
	
	if selected_menu == abilities_menu:
		if selected_button_index < character_info.abilities.size():
			description_label.text = character_info.abilities[selected_button_index].description
		else:
			description_label.text = "???"
	elif selected_menu == items_menu:
		if character_info.items.is_empty():
			character_info.items.append({"name": "Empty", "description": ""})
			update_ui()
		elif selected_button_index < character_info.items.size():
			description_label.text = character_info.items[selected_button_index].description

func on_select_attack_menu() -> void:
	selected_menu_index = 1
	selected_menu = menus[selected_menu_index]
	cursor.set_menu_type(cursor.MenuType.ABILITIES)
	update_selected_button()
	
func on_select_items_menu() -> void:
	selected_menu_index = 2
	selected_menu = menus[selected_menu_index]
	selected_button_index = 0
	cursor.set_menu_type(cursor.MenuType.ITEMS)
	update_selected_button()
	options_node.hide()
	items_node.show()
	
func on_select_option() -> void:
	match selected_button.text:
		"1. Attack":
			on_select_attack_menu()
		"2. Move":
			pass
		"3. Items":
			on_select_items_menu()
		"4. Status":
			pass
		"5. Retreat":
			on_select_retreat()
			
func on_select_ability() -> void:
	if selected_button_index < character_info.abilities.size():
		var attack = character_info.abilities[selected_button_index]
		battle_controller.on_use_attack(attack)
		cursor.disable()
		
func on_select_item() -> void:
	if selected_button_index < character_info.items.size():
		var item = character_info.items.pop_at(selected_button_index) #expensive on large arrays
		if item.name == "Empty":
			go_back()
		else:
			battle_controller.on_use_item(item)
			cursor.disable()
			update_ui()
			go_back()
	
func on_select_retreat() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main/overworld.tscn")
	
func update_ui() -> void:
	char_name_label.text = character_info.name
	
	for i in range(abilities_menu.size()):
		if i < character_info.abilities.size():
			abilities_menu[i].text = str(i + 1) + ". " + character_info.abilities[i].name
		else:
			abilities_menu[i].text = "???"
			
	for i in range(items_menu.size()):
		if i < character_info.items.size():
			items_menu[i].text = character_info.items[i].name
		else:
			items_menu[i].text = "-"
		
func update_menus() -> void:
	menus = [options_menu, abilities_menu, items_menu]
	selected_menu = menus[selected_menu_index]
	selected_button = selected_menu[selected_button_index]
	
func navigate_backward() -> void:
	if selected_menu == abilities_menu:
		if selected_button_index == 0:
			selected_button_index += (character_info.abilities.size() - 1)
			update_selected_button()
		else:
			selected_button_index = (selected_button_index - 1)
			update_selected_button()
	elif selected_menu == items_menu:
		if selected_button_index == 0:
			selected_button_index += (character_info.items.size() - 1)
			update_selected_button()
		else:
			selected_button_index = (selected_button_index - 1)
			update_selected_button()
	else:
		if selected_button_index == 0:
			selected_button_index += (selected_menu.size() - 1)
			update_selected_button()
		else:
			selected_button_index = (selected_button_index - 1)
			update_selected_button()

func navigate_forward():
	if selected_menu == abilities_menu:
		selected_button_index = (selected_button_index + 1) % character_info.abilities.size()
		update_selected_button()
	elif selected_menu == items_menu:
		selected_button_index = (selected_button_index + 1) % character_info.items.size()
		update_selected_button()
	else:
		selected_button_index = (selected_button_index + 1) % selected_menu.size()
		update_selected_button()

func go_back():
	if selected_menu == items_menu:
		items_node.hide()
		options_node.show()
	if selected_menu != options_menu:
		selected_menu_index = 0
		selected_menu = menus[selected_menu_index]
		selected_button_index = 0
		cursor.set_menu_type(cursor.MenuType.OPTIONS)
		update_selected_button()
		description_label.text = ""
	
