extends Control

@onready var battle_controller = $"../BattleController"
@onready var battle_cursor = $Cursor
@onready var options_node = $MainMenu
@onready var abilities_node = $AbilitiesMenu
@onready var items_node = $ItemsMenu
@onready var targets_node = $TargetsMenu
@onready var pass_turn_node = $PassTurnMenu
@onready var targets_grid = $TargetsGrid
@onready var log_node = $DialogBox
@onready var char_name_label = $MainMenu/Menu/CharPanel/NameLabel
@onready var description_label = $Descriptions/Labels/AbilityDescription
@onready var energy_cost_label = $Descriptions/Labels/AbilityStats/EnergyCost
@onready var ap_cost_label = $Descriptions/Labels/AbilityStats/ApCost
@onready var range_label = $Descriptions/Labels/AbilityStats/Range

var current_player: Node
#var grid_info: Dictionary
var options_menu = BaseMenu.new()

var abilities_menu = BaseMenu.new()
var items_menu = BaseMenu.new()
var targets_menu = BaseGridMenu.new()
var movement_menu = BaseGridMenu.new()
var pass_turn_menu = BaseMenu.new()
var log_menu = BaseLog.new()

var selected_menu: BaseMenu
var menus: Array
var cursor: BaseCursor

func _ready() -> void:
	#grid_info = battle_controller.get_grid_info()
	initialize_menus()
	var initial_cursor_position = Vector2(0, 55)
	cursor.move_cursor(initial_cursor_position)

func _input(e) -> void:
	if not cursor.disabled:
		if Input.is_action_just_pressed("navigate_forward"):
			selected_menu.navigate_forward(e)
		elif Input.is_action_just_pressed("navigate_backward"):
			selected_menu.navigate_backward(e)
		elif Input.is_action_just_pressed("navigate_log"):
			if selected_menu != log_menu:
				navigate_log()
		elif Input.is_action_just_pressed("go_back"):
				go_back()
	update_description()

	if Input.is_action_just_pressed("ui_accept"):
		if battle_controller.manual_increment:
			battle_controller.increment_event_queue()
		if not cursor.disabled:
			update_scroll_size()
			on_press_button()

func go_back():
	match selected_menu:
		options_menu:
			options_menu.hide_menu()
			pass_turn_menu.show_menu()
			update_selected_menu(Data.BattleMenuType.PASS_TURN)
			return
		targets_menu:
			on_cancel_target_select()
			log_menu.hide_menu()
			update_selected_menu(Data.BattleMenuType.ABILITIES)
			return
		pass_turn_menu:
			options_menu.show_menu()
			pass_turn_menu.hide_menu()
		items_menu:
			items_menu.hide_menu()
			log_menu.show_menu()
		abilities_menu:
			abilities_menu.hide_menu()
			log_menu.show_menu()
		log_menu:
			pass_turn_menu.hide_menu()
			
	update_selected_menu(Data.BattleMenuType.OPTIONS)

func navigate_log() -> void:
	update_selected_menu(Data.BattleMenuType.LOG)

func update_selected_menu(selected_menu_index: int) -> void:
	selected_menu.disactivate()
	if selected_menu != options_menu && selected_menu != log_menu && selected_menu != pass_turn_menu:
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
	elif selected_menu == log_menu:
		log_menu.update_entries(battle_controller.battle_log)
		
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
		movement_menu:
			on_select_movement()
		pass_turn_menu:
			on_pass_turn()

func on_select_option() -> void:
	match selected_menu.get_selected_button().text:
		" Abilities":
			log_menu.hide_menu()
			update_selected_menu(Data.BattleMenuType.ABILITIES)
		" Move":
			on_select_move()
		" Guard":
			on_select_guard()
		" Items":
			log_menu.hide_menu()
			update_selected_menu(Data.BattleMenuType.ITEMS)
		" Aim":
			on_select_aim()
		" Status":
			pass
		" Retreat":
			on_select_retreat()

func on_select_ability() -> void:
	log_menu.show_menu()
	
	var ability_name = selected_menu.get_selected_button().text
	var ability_info = battle_controller.prompt_select_target(ability_name)
	if ability_info.is_empty():
		update_selected_menu(Data.BattleMenuType.OPTIONS)
		return
	
	match ability_info.target_type:
		Data.TargetType.ENEMY:
			targets_menu.activate_enemy_grid()
		Data.TargetType.HERO:
			targets_menu.activate_hero_grid()
	
	var is_out_of_range = current_player.grid_position.x + ability_info.range.x < 4 && ability_info.range != Vector2i.ZERO # hard coded 4
	var no_melee_targets = ability_info.shape == Data.AbilityShape.MELEE && ability_info.target_cells.is_empty()
	
	if is_out_of_range || no_melee_targets:
		battle_controller.prompt_out_of_range()
		update_selected_menu(Data.BattleMenuType.OPTIONS)
		return
	
	if ability_info.shape == Data.AbilityShape.MELEE:
		targets_menu.set_custom_cells(ability_info.target_cells)
	else:
		targets_menu.set_current_shape(ability_info.shape)
		targets_menu.set_range(current_player.grid_position, ability_info.range)
	
	update_selected_menu(Data.BattleMenuType.TARGETS)

func on_select_item() -> void:
	var index = selected_menu.get_selected_button_index()
	var item_name = current_player.items[index].name
	if item_name == "Empty":
		go_back()
	else:
		log_menu.show_menu()
		battle_controller.on_use_item(index)
		go_back()
		items_menu.set_scroll_size(current_player.items.size())
	
func on_select_move() -> void:
	update_selected_menu(Data.BattleMenuType.MOVEMENT)
	movement_menu.activate_hero_grid()
	movement_menu.set_current_shape(Data.AbilityShape.SINGLE)
	movement_menu.set_range(current_player.grid_position, current_player.move_range)
	battle_controller.prompt_select_space()
	
func on_select_aim() -> void:
	battle_controller.on_aim()
	update_selected_menu(Data.BattleMenuType.OPTIONS)
	
func on_select_guard() -> void:
	#var coords = current_player.grid_position
	#targets_menu.set_guarded_cells(coords)
	battle_controller.on_guard()
	update_selected_menu(Data.BattleMenuType.OPTIONS)
	
func on_select_target():
	log_menu.show_menu()
	var target_cells = targets_menu.get_target_cells()
	var valid_targets = battle_controller.get_targets(target_cells)
	if !valid_targets.is_empty():
		battle_controller.on_use_ability(valid_targets)
		abilities_menu.set_scroll_size(current_player.current_abilities.size()) # will be called on end turn
		update_selected_menu(Data.BattleMenuType.OPTIONS)
	else:
		battle_controller.on_select_invalid_target()
		
func on_cancel_target_select() -> void:
	battle_controller.cancel_select_target()

func on_select_retreat() -> void:
	battle_controller.on_try_retreat()
	
func on_select_movement() -> void:
	var cell_coords: Array = movement_menu.get_target_cells()
	var targets = battle_controller.get_targets(cell_coords, true)
	if targets.is_empty():
		battle_controller.on_movement(cell_coords[0])
		go_back()
		
func on_pass_turn() -> void:
	var index = selected_menu.get_selected_button_index()
	match index:
		0:
			battle_controller.end_turn()
			go_back()
		1:
			go_back()
	
func update_description() -> void:
	var index = selected_menu.get_selected_button_index()
	if selected_menu == abilities_menu:
		description_label.text = current_player.current_abilities[index].description
		energy_cost_label.text = str("EP cost: ", current_player.current_abilities[index].energy_cost)
		ap_cost_label.text = str("AP cost: ", current_player.current_abilities[index].action_cost)
		var range = current_player.current_abilities[index].range
		range_label.text = str("Range: (", range.x, ", ", range.y, ")")
	elif selected_menu == items_menu:
		if index < current_player.items.size():
			description_label.text = current_player.items[index].menu_description
	elif selected_menu == options_menu:
		description_label.text = "Press Q to pass turn"
		energy_cost_label.text = "Ep cost: "
		ap_cost_label.text = "Ap cost: "
		range_label.text =  "Range: "

func initialize_menus() -> void:
	var initial_cursor_pos = Vector2i(0, 65)
	cursor = battle_cursor
	
	var options_buttons = options_node.get_child(0).get_children().slice(1)
	options_menu.init(options_node, options_buttons, cursor, null)
	
	var abilities_buttons = abilities_node.get_child(0).get_children().slice(3)
	abilities_menu.init(abilities_node, abilities_buttons, cursor, initial_cursor_pos)
	
	var items_buttons = items_node.get_child(0).get_children().slice(3)
	items_menu.init(items_node, items_buttons, cursor, initial_cursor_pos)
	
	var targets_buttons = targets_grid.get_children()
	targets_menu.init(targets_node, targets_buttons, cursor, null, false) # wrapping is false
	movement_menu.init(targets_node, targets_buttons, cursor, null, false) # wrapping is false
	
	log_menu.init(log_node, log_node.get_child(0).get_children().slice(1), cursor, null, battle_controller.battle_log)
	
	var initial_pass_turn_cursor_pos = Vector2i(0, 90)
	var pass_turn_buttons = pass_turn_node.get_child(0).get_children().slice(1)
	pass_turn_menu.init(pass_turn_node, pass_turn_buttons, cursor, initial_pass_turn_cursor_pos)
	
	menus = [options_menu, abilities_menu, items_menu, targets_menu, log_menu, movement_menu, pass_turn_menu]
	selected_menu = options_menu
	update_description()
	selected_menu.activate()
	
#func build_targets_cells() -> Array[Panel]:
	#var cells: Array[Panel]
	#for i in range(32): # battle_controller.get_grid_size() x * y
		#var cell = Panel.new()
		#cell.size_flags_horizontal = SIZE_EXPAND_FILL
		#cell.size_flags_vertical = SIZE_EXPAND_FILL
		#var style = StyleBoxFlat.new()
		#style.bg_color = Color(1, 1, 1)
		#cell.add_theme_stylebox_override("panel", style)
		#cell.z_index = -1
		#cells.append(cell)
	#return cells
	
func update_scroll_size() -> void:
	current_player = battle_controller.get_current_player()
	abilities_menu.set_scroll_size(current_player.current_abilities.size())
	items_menu.set_scroll_size(current_player.items.size())
