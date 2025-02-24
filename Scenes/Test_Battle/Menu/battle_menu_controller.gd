extends Control

@onready var battle_cursor = $Cursor
@onready var options_node = $MainMenu
@onready var abilities_node = $AbilitiesMenu
@onready var items_node = $ItemsMenu
@onready var targets_node = $TargetsMenu
@onready var log_node = $DialogBox
@onready var char_name_label = $MainMenu/Menu/CharPanel/NameLabel
@onready var player = $"../Player"
@onready var battle_controller = $"../BattleController"
@onready var description_label = $Descriptions/Labels/AbilityDescription
@onready var enemy = $"../Enemy"

var enemies: Array
var players: Array
var initial_cursor_position = Vector2(0, 40)

var options_menu = BaseMenu.new()
var abilities_menu = BaseMenu.new()
var items_menu = BaseMenu.new()
var targets_menu = BaseMenu.new()
var log_menu = BaseLog.new()

var selected_menu: BaseMenu
var menus: Array
var cursor: BaseCursor

func _ready() -> void:
	initialize_menus()
	update_ui()
	cursor.move_cursor(initial_cursor_position)

func _input(_e) -> void:
	if not cursor.disabled:
		if Input.is_action_just_pressed("navigate_forward"):
			selected_menu.navigate_forward()
			update_description()

		elif Input.is_action_just_pressed("navigate_backward"):
			selected_menu.navigate_backward()
			update_description()
		
		elif Input.is_action_just_pressed("navigate_log"):
			if selected_menu != log_menu:
				navigate_log()
			
		elif Input.is_action_just_pressed("go_back"):
			if selected_menu == targets_menu:
				on_cancel_target_select()
			elif selected_menu == log_menu:
				cursor.enable()
				go_back()
			else:
				go_back()

	if Input.is_action_just_pressed("ui_accept"):
		if battle_controller.manual_increment:
			battle_controller.increment_queue()
		if not cursor.disabled:
			on_press_button()

func go_back():
	if selected_menu != options_menu:
		log_menu.show_menu()
		items_menu.hide_menu()
		abilities_menu.hide_menu()
		update_selected_menu(Enums.BattleMenuType.OPTIONS)
		description_label.text = ""

func navigate_log() -> void:
	update_selected_menu(Enums.BattleMenuType.LOG)

func update_selected_menu(selected_menu_index: int) -> void:
	selected_menu.disactivate()
	if selected_menu != options_menu && selected_menu != log_menu:
		selected_menu.hide_menu()
	selected_menu = menus[selected_menu_index]
	cursor.set_menu_type(selected_menu_index)
	selected_menu.activate() # activating a menu makes it visible as well
	
	if selected_menu == items_menu:
		abilities_menu.hide_menu()
		items_menu.show_menu()
		update_description()
	elif selected_menu == abilities_menu:
		update_description()
		
func on_press_button() -> void:
	match selected_menu:
		options_menu:
			on_select_option()
		abilities_menu:
			on_select_ability()
		items_menu:
			on_select_item()
		targets_menu:
			on_select_target()

func on_select_option() -> void:
	match selected_menu.selected_button.text:
		" Attack":
			log_menu.hide_menu()
			update_selected_menu(Enums.BattleMenuType.ABILITIES)
		" Move":
			pass
		" Items":
			log_menu.hide_menu()
			update_selected_menu(Enums.BattleMenuType.ITEMS)
		" Status":
			pass
		" Retreat":
			on_select_retreat()

func on_select_ability() -> void:
	log_menu.show_menu()
	var selected_attack = player.abilities_dictionary[selected_menu.selected_button.text]
	update_selected_menu(Enums.BattleMenuType.TARGETS)
	battle_controller.prompt_select_target(selected_attack)

func on_select_target():
	log_menu.show_menu() # will change once targets menu exists
	var target = selected_menu.selected_button
	battle_controller.on_use_attack(target.alignment)
	go_back()

func on_cancel_target_select() -> void:
	log_menu.hide_menu()
	update_selected_menu(Enums.BattleMenuType.ABILITIES)
	battle_controller.cancel_select_target()

func on_select_item() -> void:
	var item = player.items.pop_at(selected_menu.get_selected_button_index()) # expensive on large arrays
	if player.items.is_empty():
		player.items.append({"name": "Empty", "menu_description": "You have no items"})
		update_ui()
	if item.name == "Empty":
		go_back()
	else:
		log_menu.show_menu()
		battle_controller.on_use_item(item)
		update_ui()
		go_back()
	items_menu.set_scroll_size(player.items.size())

func on_select_retreat() -> void:
	battle_controller.on_try_retreat()

func update_ui() -> void:
	cursor = battle_cursor
	char_name_label.text = player.name

	for i in range(abilities_menu.buttons.size()):
		if i < player.abilities.size():
			abilities_menu.buttons[i].text = player.abilities[i].name
		else:
			abilities_menu.buttons[i].text = "???"

	for i in range(items_menu.buttons.size()):
		if i < player.items.size():
			items_menu.buttons[i].text = player.items[i].name
		else:
			items_menu.buttons[i].text = "-"
			
func update_description() -> void:
	var index = selected_menu.get_selected_button_index()
	if selected_menu == abilities_menu:
		description_label.text = player.abilities[index].description
	elif selected_menu == items_menu:
		if index < player.items.size():
			description_label.text = player.items[index].menu_description

func initialize_menus() -> void:
	var initial_button_position = Vector2i(0, 65)
	
	var options_buttons = options_node.get_child(0).get_children().slice(1)
	options_menu.init(options_node, options_buttons, battle_cursor, null)
	
	var abilities_buttons = abilities_node.get_child(0).get_children().slice(3)
	abilities_menu.init(abilities_node, abilities_buttons, battle_cursor, initial_button_position)
	abilities_menu.set_scroll_size(player.abilities.size())
	
	var items_buttons = items_node.get_child(0).get_children().slice(3)
	items_menu.init(items_node, items_buttons, battle_cursor, initial_button_position)
	items_menu.set_scroll_size(player.items.size())
	
	enemies = [enemy]
	targets_menu.init(targets_node, enemies, battle_cursor, null)
	targets_menu.set_scroll_size(enemies.size())
	
	log_menu.init(log_node, log_node.get_child(0).get_children().slice(1), battle_cursor, null)
	log_menu.set_entries(battle_controller.battle_log)
	
	menus = [options_menu, abilities_menu, items_menu, targets_menu, log_menu]
	selected_menu = options_menu
	selected_menu.activate()
	
