extends Node2D

@onready var game_controller = get_tree().current_scene
@onready var dialog_box = $"../BattleMenu/DialogBox/BattleLog".get_children().slice(1)
@onready var cursor = $"../BattleMenu/Cursor"

@onready var char_name_label = $"../BattleMenu/MainMenu/Menu/CharPanel/NameLabel"
@onready var items_node = $"../BattleMenu/ItemsMenu"
@onready var abilities_node = $"../BattleMenu/AbilitiesMenu"

var norman_scene = preload("res://Scenes/Battle/Characters/Norman/norman.tscn")
var thumper_scene = preload("res://Scenes/Battle/Characters/Thumper/thumper.tscn")
var pc_scene = preload("res://Scenes/Battle/Characters/PC/pc.tscn")
var runt_scene = preload("res://Scenes/Battle/Characters/Runt/runt.tscn")

var players: Array[Character]
var current_player: Character

var battle_grid: BaseGrid = BaseGrid.new()

var event_queue: Array
var turn_queue: Array

var initial_dialog: String = "Two lil' guys appeared!"
var battle_log: Array
var dialog: Label
var manual_increment: bool = false

var dialog_duration: float = 0.9
var attack_duration: float = 0.9

var selected_attack: Dictionary

enum EventType {
	DIALOG,
	ATTACK,
	DEATH,
	RETREAT,
	END_TURN
}

func _ready() -> void:
	cursor.disable()
	initialize_battle()
	add_event({"type": EventType.DIALOG, "text": initial_dialog})
	add_event({"type": EventType.DIALOG, "text": current_player.char_name + "'s turn!", "duration": dialog_duration})
	if current_player.alliance == GameData.Alliance.ENEMY:
		perform_enemy_attack()
	else:
		increment_event_queue()

func add_event(event) -> void:
	event_queue.append(event)

func clear_queue() -> void:
	event_queue.clear()

func increment_event_queue() -> void:
	manual_increment = false
	
	var event = event_queue.pop_front()
	if event:
		match event.type:
			EventType.DIALOG:
				handle_dialog(event)
			EventType.ATTACK:
				handle_attack(event)
			EventType.DEATH:
				handle_death(event)
			EventType.RETREAT:
				handle_retreat()
			EventType.END_TURN:
				handle_end_turn()

		if event.has("duration"):
			await wait(event.duration)
			increment_event_queue() # can recursively call itself :O
		else:
			manual_increment = true
	else:
		if current_player.alliance == GameData.Alliance.HERO:
			manual_increment = false
			cursor.enable()
		elif current_player.alliance == GameData.Alliance.ENEMY:
			perform_enemy_attack()

func handle_dialog(event: Dictionary) -> void:
	dialog.text = event.text
	battle_log.append(event.text)
	update_dialog_queue()

func play_dialog(text: String, should_log: bool) -> void:
	dialog.text = text
	if should_log:
		battle_log.append(text)
		update_dialog_queue()

func update_dialog_queue() -> void:
	for i in range(dialog_box.size()):
		if i < battle_log.size():
			dialog_box[i].text = battle_log[(battle_log.size() - 1) - i]
	dialog_box[0].modulate = Color(1, 1, 0)
	if battle_log.size() > 20:
		battle_log = battle_log.slice(1)

func handle_attack(event: Dictionary) -> void:
	var attack_result = event.target.take_damage(event.damage_event)
	if attack_result.damage:
		play_dialog(event.target.char_name + " took " + str(attack_result.damage) + " damage!", true)
		if attack_result.effect_dialog:
			add_event({"type": EventType.DIALOG, "text": event.target.char_name + " took " + attack_result.effect_dialog + "!", "duration": dialog_duration})
	elif attack_result.effect_dialog:
		play_dialog(event.target.char_name + " took " + attack_result.effect_dialog + "!", true)
	if event.target.health_bar.value <= 0:
		on_target_death(event.target)

func on_use_attack(target_cells: Array) -> void:
	cursor.disable()
	var selected_targets: Array
	for cell in target_cells: # move to base grid
		if battle_grid.current_grid.has(cell):
			selected_targets.append(cell)
	var damage_event = calculate_attack_dmg()
	add_event({"type": EventType.DIALOG, "text": current_player.char_name + " used " + selected_attack.name + "!", "duration": dialog_duration, "publisher": current_player.char_name})
	for target in selected_targets:
		add_event({"type": EventType.ATTACK, "target": battle_grid.current_grid[target], "damage_event": damage_event, "duration": attack_duration, "publisher": current_player.char_name})
	add_event({"type": EventType.END_TURN, "duration": 0})
	increment_event_queue()

func prompt_select_target(attack_name: String) -> Dictionary:
	var hero_attack = GameData.abilities[attack_name]
	selected_attack = hero_attack
	play_dialog("Select a target!", false)
	return {"target": hero_attack.target, "shape": hero_attack.shape, "target_type": selected_attack.target_type}

func cancel_select_target() -> void:
	selected_attack = {}

func on_select_invalid_target() -> void:
	play_dialog("Not a valid target!", false)
		
func on_use_item(item_index: int) -> void:
	cursor.disable()
	var item = current_player.items.pop_at(item_index) # expensive on large arrays
	if current_player.items.is_empty():
		current_player.items.append({"name": "Empty", "menu_description": "You have no items"})
	update_ui()
	
	add_event({"type": EventType.DIALOG, "text": str(current_player.char_name, " used " + item.name + "!"), "duration": dialog_duration, "publisher": current_player.char_name})
	current_player.items_equipped.append(item)
	current_player.populate_buffs_array()
	add_event({"type": EventType.DIALOG, "text": item.effect_description, "duration": dialog_duration, "publisher": current_player.char_name})
	add_event({"type": EventType.END_TURN, "duration": 0, "publisher": current_player.char_name})
	increment_event_queue()

func on_try_retreat() -> void:
	cursor.disable()
	add_event({"type": EventType.DIALOG, "text": "Player retreats!", "duration": dialog_duration})
	var success: bool = current_player.health_bar.value > randi() % 50
	if success:
		add_event({"type": EventType.DIALOG, "text": "Got away safely!"})
		add_event({"type": EventType.RETREAT})
	else:
		add_event({"type": EventType.DIALOG, "text": "But it failed!", "duration": dialog_duration})
	increment_event_queue()

func calculate_attack_dmg() -> Dictionary:
	var damage: int = selected_attack.damage
	var damage_with_range = damage * randf_range(.9, 1.1)
	var effect: Dictionary = selected_attack.effect
	var attribute_multiplier = resolve_attribute_bonuses()
	if attribute_multiplier:
		damage *= float(attribute_multiplier)
	return {"damage": damage_with_range, "damage_type": selected_attack.damage_type, "effect": effect}
	
func resolve_attribute_bonuses():
	var attribute = selected_attack.attribute_bonus
	if attribute != GameData.Attributes.NONE:
		var value: float = current_player.attributes[attribute]
		var multiplier: float = 1 + (value / 10)
		return multiplier

func perform_enemy_attack() -> void:
	var target
	for player in players:
		if player.alliance == GameData.Alliance.HERO:
			target = player
			break
	
	var enemy_attack = get_enemy_attack()
	var damage_event = calculate_attack_dmg()
	
	add_event({"type": EventType.DIALOG, "text": current_player.char_name + " used " + enemy_attack.name + "!", "duration": dialog_duration, "publisher": current_player.char_name})
	add_event({"type": EventType.ATTACK, "target": target, "damage_event": damage_event, "duration": attack_duration, "publisher": current_player.char_name})
	add_event({"type": EventType.END_TURN, "duration": 0, "publisher": current_player.char_name})
	
	increment_event_queue()
	
func get_enemy_attack() -> Dictionary:
	var attack_index = randi() % current_player.abilities.size()
	var attack = current_player.abilities[attack_index]
	selected_attack = attack
	return attack

func on_target_death(target: Character) -> void:
	battle_grid.current_grid.erase(target.grid_position)
	players = players.filter(func(p): return p.char_name != target.char_name)
	event_queue = event_queue.filter(func(e): return !e.has("publisher") || e.publisher != target.char_name || e.has("target") && e.target.char_name != target.char_name) # make sure this works
	turn_queue = turn_queue.filter(func(c): return c.char_name != target.char_name)
	add_event({"type": EventType.DIALOG, "text": target.char_name + " died!", "duration": dialog_duration})
	add_event({"type": EventType.DEATH, "target": target})
	
func resolve_item_effect() -> float:
	var buff = current_player.buffs.get(selected_attack.damage_type, 0) + 1
	return buff
	
func handle_end_turn() -> void:
	increment_turn_queue()
	add_event({"type": EventType.DIALOG, "text": current_player.char_name + "'s turn!", "duration": dialog_duration, "publisher": current_player.char_name})
	update_ui()

func handle_retreat() -> void:
	game_controller.switch_to_overworld_scene()

func handle_death(event) -> void:
	if event.target.is_player:
		game_controller.switch_to_overworld_scene()
	else:
		event.target.visible = false
		increment_event_queue()

func check_valid_targets(target_cells: Array) -> bool:
	var valid_targets: Array[Vector2i]
	var occupied_cells = battle_grid.current_grid.keys()
	for cell in occupied_cells:
		if selected_attack.target == GameData.TargetType.ENEMY:
			if cell.x > 3: # if master grid width is constant, will always be '3'
				valid_targets.append(cell)
		elif selected_attack.target == GameData.TargetType.HERO:
			if cell.x < 4:
				valid_targets.append(cell)
	var is_valid_target: bool = false
	for cell in target_cells:
		if valid_targets.has(cell):
			is_valid_target = true
	return is_valid_target

func build_characters() -> void:
	var pc = pc_scene.instantiate()
	var pc_abilities = ["Clobber", "Laser"]
	var pc_items = ["Extra Rock", "Extra Paper", "Sharpener"]
	pc.init("PC", GameData.Alliance.HERO, pc.get_node("CharSprite"), pc.get_node("CharHealth"), 300, pc_abilities, Vector2i(2, 0), pc_items) # init props will be accessed from somewhere
	set_position_by_grid_coords(pc)
	pc.is_player = true
	add_child(pc)
	players.append(pc)
	
	var runt = runt_scene.instantiate()
	var runt_abilities = ["Bite", "Reinforce"]
	var runt_items = ["Extra Rock", "Extra Paper", "Sharpener"]
	runt.init("Runt", GameData.Alliance.HERO, runt.get_node("CharSprite"), runt.get_node("CharHealth"), 300, runt_abilities, Vector2i(3, 0), runt_items) # init props will be accessed from somewhere
	set_position_by_grid_coords(runt)
	add_child(runt)
	players.append(runt)
	runt.flip_sprite()
	
	var norman = norman_scene.instantiate()
	var norman_abilities = ["Clobber"]
	norman.init("Norman", GameData.Alliance.ENEMY, norman.get_node("CharSprite"), norman.get_node("CharHealth"), 300, norman_abilities, Vector2i(5, 0)) # init props will be accessed from somewhere
	set_position_by_grid_coords(norman)
	add_child(norman)
	players.append(norman)
	
	var thumper = thumper_scene.instantiate()
	var thumper_abilities = ["Clobber", "Bite"]
	thumper.init("Thumper", GameData.Alliance.ENEMY, thumper.get_node("CharSprite"), thumper.get_node("CharHealth"), 300, thumper_abilities, Vector2i(6, 0)) # init props will be accessed from somewhere
	set_position_by_grid_coords(thumper)
	add_child(thumper)
	thumper.flip_sprite()
	players.append(thumper)
			
func populate_grid() -> void:
	for player in players:
		battle_grid.set_object_at_grid_position(player)
	
func set_grid_cells() -> Vector2i:
	# will create grid shape for the batlle
	return Vector2i(8, 4)
	
func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
	
func get_player_info() -> Dictionary:
	return {"name": current_player.char_name, "abilities": current_player.abilities, "items": current_player.items, "alliance": current_player.alliance}
	
func get_grid_info() -> Dictionary:
	return {"current_grid": battle_grid.current_grid, "grid_size": set_grid_cells()}
	
func set_position_by_grid_coords(character: Character) -> void:
	var coords = character.grid_position
	var x_pos = 192 + (coords.x * 128) # const grid_span = 128, const grid_offset = 192
	var y_pos = coords.y + 390
	character.position = Vector2i(x_pos, y_pos)

func set_turn_order() -> void: # pseudo turn order decider
	players.shuffle()
	turn_queue.append_array(players)
	
func increment_turn_queue() -> void:
	if turn_queue.is_empty():
		set_turn_order()
	var next_player = turn_queue.pop_front()
	current_player = next_player
	
func update_ui() -> void:
	if current_player.alliance == GameData.Alliance.HERO:	
		char_name_label.text = current_player.name

		var abilities_buttons = abilities_node.get_child(0).get_children().slice(3)
		for i in range(abilities_buttons.size()):
			if i < current_player.abilities.size():
				abilities_buttons[i].text = current_player.abilities[i].name
			else:
				abilities_buttons[i].text = "???"

		var items_buttons = items_node.get_child(0).get_children().slice(3)
		for i in range(items_buttons.size()):
			if i < current_player.items.size():
				items_buttons[i].text = current_player.items[i].name
			else:
				items_buttons[i].text = "-"
				
func initialize_battle() -> void:
	dialog = dialog_box[0]
	build_characters()
	populate_grid()
	increment_turn_queue()
	update_ui()
