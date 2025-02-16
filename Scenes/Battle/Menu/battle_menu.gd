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
@onready var player = $"../Player"
@onready var enemy = $"../Enemy"

var selected_button_index: int = 0
var selected_button: Node

var menus: Array
var selected_menu: Array
var targets_menu: Array = []

var initial_cursor_position: Vector2 = Vector2(0, 45)

# using process_frame seems to help avoid race issues w/ updating cursor position
func _ready() -> void:
	items_node.hide()
	update_ui()
	update_menus()
	await get_tree().process_frame
	cursor.move_cursor(initial_cursor_position)
	
func _input(_e) -> void:
	if not cursor.disabled:
		var menu_size = get_menu_size()
			
		if Input.is_action_just_pressed("navigate_backward"):
			navigate_backward(menu_size)
				
		elif Input.is_action_just_pressed("navigate_forward"):
			navigate_forward(menu_size)
			
		elif Input.is_action_just_pressed("go_back"):
			if selected_menu == targets_menu:
				on_cancel_target_select()
			else:
				go_back()
			
	if Input.is_action_just_pressed("ui_accept"):
		if not battle_controller.event_queue.is_empty():
			battle_controller.increment_queue()
		else:
			match selected_menu:
				options_menu:
					on_select_option()	
				abilities_menu:
					on_select_ability()
				items_menu:
					on_select_item()
				targets_menu:
					on_select_target()
 
# using process_frame seems to help avoid race issues w/ updating cursor position
func update_selected_button() -> void:
	selected_button = selected_menu[selected_button_index]
	await get_tree().process_frame
	cursor.move_cursor(selected_button.position)
	
	if selected_menu == abilities_menu:
		description_label.text = player.abilities[selected_button_index].description
	elif selected_menu == items_menu:
		if player.items.is_empty():
			player.items.append({"name": "Empty", "menu_description": ""})
			update_ui()
		else:
			if selected_button_index < player.items.size():
				description_label.text = player.items[selected_button_index].menu_description

func update_selected_menu(selected_menu_index: int) -> void:
	selected_menu = menus[selected_menu_index]
	cursor.set_menu_type(selected_menu_index)
	selected_button_index = 0
	update_selected_button()
	if cursor.selected_menu_type == cursor.MenuType.ITEMS:
		options_node.hide()
		items_node.show()
	
func on_select_option() -> void:
	match selected_button.text:
		" Attack":
			update_selected_menu(1)
		" Move":
			pass
		" Items":
			update_selected_menu(2)
		" Status":
			pass
		" Retreat":
			on_select_retreat()
			
func on_select_ability() -> void:
	var selected_attack = player.abilities[selected_button_index]
	update_selected_menu(3)
	selected_button_index = 0
	update_selected_button()
	battle_controller.prompt_select_target(selected_attack)
	
func on_select_target():
	var target = targets_menu[selected_button_index]
	battle_controller.on_use_attack(target.alignment)
	go_back()
		
func on_select_item() -> void:
	var item = player.items.pop_at(selected_button_index) # expensive on large arrays
	if item.name == "Empty":
		go_back()
	else:
		battle_controller.on_use_item(item)
		update_ui()
		go_back()
	
func on_select_retreat() -> void:
	battle_controller.on_try_retreat()
	
func update_ui() -> void:
	char_name_label.text = player.name
	
	for i in range(abilities_menu.size()):
		if i < player.abilities.size():
			abilities_menu[i].text = player.abilities[i].name
		else:
			abilities_menu[i].text = "???"
			
	for i in range(items_menu.size()):
		if i < player.items.size():
			items_menu[i].text = player.items[i].name
		else:
			items_menu[i].text = "-"
		
func update_menus() -> void:
	menus = [options_menu, abilities_menu, items_menu, targets_menu]
	targets_menu.append(enemy)
	selected_menu = menus[0]
	selected_button = selected_menu[selected_button_index]
	
func navigate_backward(menu_size: int) -> void:
		if selected_button_index == 0:
			selected_button_index += (menu_size - 1)
			update_selected_button()
		else:
			selected_button_index -= 1
			update_selected_button()

func navigate_forward(menu_size: int):
	selected_button_index = (selected_button_index + 1) % menu_size
	update_selected_button()

func go_back():
	if selected_menu == items_menu:
		items_node.hide()
		options_node.show()
	if selected_menu != options_menu:
		update_selected_menu(0)
		description_label.text = ""
		
		
func get_menu_size() -> int:
	var menu_size: int
	match selected_menu:
		abilities_menu:
			menu_size = player.abilities.size()
		items_menu:
			menu_size = player.items.size()
		targets_menu:
			menu_size = targets_menu.size()
		_:
			menu_size = selected_menu.size()
	return menu_size
	
func on_cancel_target_select() -> void:
	update_selected_menu(1)
	battle_controller.cancel_select_target()
