extends Control

@onready var battle_cursor = $Cursor
@onready var options_node = $MainMenu
@onready var abilities_node = $AbilitiesMenu
@onready var items_node = $ItemsMenu
@onready var targets_node = $TargetsMenu
@onready var targets_grid = $TargetsGrid
@onready var log_node = $DialogBox
@onready var char_name_label = $MainMenu/Menu/CharPanel/NameLabel
@onready var battle_controller = $"../BattleController"
@onready var description_label = $Descriptions/Labels/AbilityDescription

var enemies: Array
var player_info: Dictionary
var grid_info: Dictionary
var initial_cursor_position = Vector2(0, 40)

var options_menu = BaseMenu.new()
var abilities_menu = BaseMenu.new()
var items_menu = BaseMenu.new()
var targets_menu = BaseGridMenu.new()
var log_menu = BaseLog.new()

var selected_menu: BaseMenu
var menus: Array
var cursor: BaseCursor

func _ready() -> void:
	player_info = battle_controller.get_player_info()
	grid_info = battle_controller.get_grid_info()
	initialize_menus()
	update_ui()
	cursor.move_cursor(initial_cursor_position)

func _input(e) -> void:
	if not cursor.disabled:
		if Input.is_action_just_pressed("navigate_forward"):
			selected_menu.navigate_forward(e)
			update_description()

		elif Input.is_action_just_pressed("navigate_backward"):
			selected_menu.navigate_backward(e)
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
			battle_controller.increment_event_queue()
		if not cursor.disabled:
			on_press_button()

func go_back():
	if selected_menu != options_menu:
		log_menu.show_menu()
		items_menu.hide_menu()
		abilities_menu.hide_menu()
		update_selected_menu(GameData.BattleMenuType.OPTIONS)
		description_label.text = ""

func navigate_log() -> void:
	update_selected_menu(GameData.BattleMenuType.LOG)

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
	match selected_menu.get_selected_button().text:
		" Attack":
			log_menu.hide_menu()
			update_selected_menu(GameData.BattleMenuType.ABILITIES)
		" Move":
			pass
		" Items":
			log_menu.hide_menu()
			update_selected_menu(GameData.BattleMenuType.ITEMS)
		" Status":
			pass
		" Retreat":
			on_select_retreat()

func on_select_ability() -> void:
	log_menu.show_menu()
	var attack_name = selected_menu.get_selected_button().text
	var attack_info = battle_controller.prompt_select_target(attack_name)
	targets_menu.set_current_shape(attack_info.shape)
	if attack_info.target == GameData.TargetType.ENEMY:
		if targets_menu.current_grid_type != targets_menu.GridType.ENEMY:
			targets_menu.activate_enemy_grid()
	elif attack_info.target == GameData.TargetType.HERO:
		targets_menu.activate_player_menu()
	update_selected_menu(GameData.BattleMenuType.TARGETS)

func on_select_target():
	log_menu.show_menu()
	var target_cells = targets_menu.get_targeted_cells()
	var is_valid_target = battle_controller.check_valid_targets(target_cells)
	if is_valid_target:
		battle_controller.on_use_attack(target_cells)
		targets_menu.disactivate()
		go_back()
		update_ui()
	else:
		battle_controller.on_select_invalid_target()

func on_cancel_target_select() -> void:
	log_menu.hide_menu()
	update_selected_menu(GameData.BattleMenuType.ABILITIES)
	battle_controller.cancel_select_target()

func on_select_item() -> void:
	var index = selected_menu.get_selected_button_index()
	var item_name = player_info.items[index].name
	if item_name == "Empty":
		go_back()
	else:
		log_menu.show_menu()
		battle_controller.on_use_item(index)
		update_ui()
		go_back()
		items_menu.set_scroll_size(player_info.items.size())

func on_select_retreat() -> void:
	battle_controller.on_try_retreat()

func update_ui() -> void:
	var next_player_info = battle_controller.get_player_info()
	if next_player_info.alliance == GameData.Alliance.HERO:
		player_info = next_player_info
		
	char_name_label.text = player_info.name

	for i in range(abilities_menu.buttons.size()):
		if i < player_info.abilities.size():
			abilities_menu.buttons[i].text = player_info.abilities[i].name
		else:
			abilities_menu.buttons[i].text = "???"

	for i in range(items_menu.buttons.size()):
		if i < player_info.items.size():
			items_menu.buttons[i].text = player_info.items[i].name
		else:
			items_menu.buttons[i].text = "-"
			
func update_description() -> void:
	var index = selected_menu.get_selected_button_index()
	if selected_menu == abilities_menu:
		description_label.text = player_info.abilities[index].description
	elif selected_menu == items_menu:
		if index < player_info.items.size():
			description_label.text = player_info.items[index].menu_description

func initialize_menus() -> void:
	var initial_button_position = Vector2i(0, 65)
	cursor = battle_cursor
	
	var options_buttons = options_node.get_child(0).get_children().slice(1)
	options_menu.init(options_node, options_buttons, cursor, null)
	
	var abilities_buttons = abilities_node.get_child(0).get_children().slice(3)
	abilities_menu.init(abilities_node, abilities_buttons, cursor, initial_button_position)
	abilities_menu.set_scroll_size(player_info.abilities.size())
	
	var items_buttons = items_node.get_child(0).get_children().slice(3)
	items_menu.init(items_node, items_buttons, cursor, initial_button_position)
	items_menu.set_scroll_size(player_info.items.size())
	
	var targets_buttons = targets_grid.get_children()
	targets_menu.init(targets_node, targets_buttons, cursor, null)
	
	log_menu.init(log_node, log_node.get_child(0).get_children().slice(1), cursor, null, battle_controller.battle_log)
	
	menus = [options_menu, abilities_menu, items_menu, targets_menu, log_menu]
	selected_menu = options_menu
	selected_menu.activate()
