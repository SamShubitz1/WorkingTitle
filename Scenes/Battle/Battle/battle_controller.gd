extends Node2D

@onready var game_controller = get_tree().current_scene
@onready var dialog_box = $"../BattleMenu/DialogBox/BattleLog".get_children().slice(1)
@onready var cursor = $"../BattleMenu/Cursor"

@onready var health_display = $"../BattleMenu/MainMenu/Menu/CharPanel/Health"
@onready var ap_display = $"../BattleMenu/Descriptions/Labels/ActionPointDisplay"
@onready var char_name_label = $"../BattleMenu/MainMenu/Menu/CharPanel/NameLabel"
@onready var items_node = $"../BattleMenu/ItemsMenu"
@onready var abilities_node = $"../BattleMenu/AbilitiesMenu"

var kapow_scene = preload("res://Scenes/Battle/Battle/kapow_scene.tscn")
var current_kapow: Node

var norman_scene = preload("res://Scenes/Battle/Characters/Norman/norman.tscn")
var thumper_scene = preload("res://Scenes/Battle/Characters/Thumper/thumper.tscn")
var pc_scene = preload("res://Scenes/Battle/Characters/PC/pc.tscn")
var runt_scene = preload("res://Scenes/Battle/Characters/Runt/runt.tscn")
var mandrake_scene = preload("res://Scenes/Battle/Characters/Mandrake/mandrake.tscn")
var pilypile_scene = preload("res://Scenes/Battle/Characters/Pilypile/pilypile.tscn")

var players: Array[Character]
var current_player: Character

var battle_grid: BaseGrid = BaseGrid.new()

var event_queue: Array
var turn_queue: Array

var initial_dialog: String = "Three lil' guys appeared!"
var battle_log: Array
var dialog: Label
var manual_increment: bool = false

const dialog_duration: float = 0.7

var selected_ability: Dictionary

enum EventType {
	DIALOG,
	ABILITY,
	GUARD,
	MOVEMENT,
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
		perform_enemy_turn()
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
			EventType.ABILITY:
				handle_ability(event)
			EventType.GUARD:
				handle_guard(event)
			EventType.MOVEMENT:
				handle_movement(event)
			EventType.DEATH:
				handle_death(event)
			EventType.RETREAT:
				handle_retreat()
			EventType.END_TURN:
				handle_end_turn()

		if event.has("duration"):
			await wait(event.duration)
			
			if current_kapow != null:
				current_kapow.finish()
			
			increment_event_queue() # can recursively call itself :O
		else:
			manual_increment = true
	else:
		if current_player.alliance == GameData.Alliance.HERO:
			manual_increment = false
			cursor.enable()
		elif current_player.alliance == GameData.Alliance.ENEMY:
			perform_enemy_turn()

func handle_dialog(event: Dictionary) -> void:
	dialog.text = event.text
	play_dialog(dialog.text, true)
	
func handle_ability(event: Dictionary) -> void:	
	if event.has("damage_event"):
		var damage_result = event.target.take_damage(event.damage_event)
		play_dialog(event.target.char_name + " took " + str(damage_result) + " damage!", true)
		if event.has("animation"):
			current_kapow = get_kapow()
			current_kapow.start(event.target.position, event.target.z_index, event.animation)
			
		if event.target.health_bar.value <= 0:
			on_target_death(event.target)
#
	elif event.has("effect"):
		event.target.resolve_effect(event.effect)
		play_dialog(event.target.char_name + " " + event.effect.description + "!", true)
		if event.effect_animation != "":
			current_kapow = get_kapow()
			current_kapow.start(event.target.position, event.target.z_index, event.effect_animation)
			
func handle_movement(event: Dictionary) -> void:
	var target = event.target
	battle_grid.update_grid_object(target, event.next_position)
	set_position_by_grid_coords(target)
	
func handle_guard(event: Dictionary) -> void:
	var target = event.target
	current_kapow = get_kapow()
	current_kapow.start(event.target.position, event.target.z_index, event.animation)
	play_dialog(target.char_name + " is protected!", true)

func handle_death(event) -> void:
	if event.target.is_player:
		game_controller.switch_to_overworld_scene()
	else:
		event.target.visible = false
		increment_event_queue()

func handle_end_turn() -> void:
	increment_turn_queue()
	add_event({"type": EventType.DIALOG, "text": current_player.char_name + "'s turn!", "duration": dialog_duration, "emitter": current_player})
	
	current_player.start_turn()
	
	for player in players:
		if player.alliance == Data.Alliance.HERO && player.guardian == current_player:
			player.set_guardian(null)
			add_event({"type": EventType.DIALOG, "text": player.char_name + " is no longer protected!", "duration": dialog_duration})
			
	update_ui()

func handle_retreat() -> void:
	game_controller.switch_to_overworld_scene()

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

func on_use_ability(target_cells: Array) -> void:
	var cost = selected_ability.action_cost
	var ap_success = current_player.use_action(cost)
	if ap_success:
		ap_display.update_action_points(cost)
		
		var selected_targets: Array
		for cell in target_cells: # move to base grid
			if battle_grid.current_grid.has(cell):
				selected_targets.append(cell)
		
		add_event({"type": EventType.DIALOG, "text": current_player.char_name + " used " + selected_ability.name + "!", "duration": dialog_duration, "emitter": current_player})
		
		var ability_success = current_player.check_success(selected_ability)
		if ability_success:
			for target_pos in selected_targets:
				var target = battle_grid.current_grid[target_pos]
				if !selected_ability.damage.type == Data.DamageType.NONE:
					build_attack_event(target)
					
				for effect in selected_ability.effects:
					build_effect_event(target, effect)
		else:
			add_event({"type": EventType.DIALOG, "text": "But it missed!", "duration": dialog_duration, "emitter": current_player})
			
		end_turn()
	else:
		prompt_action_points_insufficient()
		
func build_attack_event(target: Character) -> void:
	var damage_event = current_player.calculate_attack_dmg(selected_ability)
	var animation = {"name": "", "duration": dialog_duration} # dummy animation because null checking is weak
	if selected_ability.has("animation"):
		animation["name"] = selected_ability.animation.name
		animation["duration"] = selected_ability.animation.duration

	add_event({"type": EventType.ABILITY, "target": target, "damage_event": damage_event, "duration": animation.duration, "emitter": current_player, "animation": animation.name})

func build_effect_event(target: Character, effect: Dictionary) -> void:
	var effect_target: Character
	var effect_animation: Dictionary = {"name": "", "duration": dialog_duration} # dummy animation because null checking is weak
				
	if effect.target == Data.EffectTarget.OTHER:
		effect_target = target
	elif effect.target == Data.EffectTarget.SELF:
		effect_target = current_player
					
	if effect.has("animation"):
		effect_animation["name"] = effect.animation.name
		effect_animation["duration"] = effect.animation.duration
					
	add_event({"type": EventType.ABILITY, "effect": effect, "target": effect_target, "duration": effect_animation.duration, "emitter": current_player, "effect_animation": effect_animation.name})

func prompt_select_target(ability_name: String) -> Dictionary:
	var hero_ability = GameData.abilities[ability_name]
	selected_ability = hero_ability
	play_dialog("Select a target!", false)
	return {"shape": hero_ability.shape, "target_type": selected_ability.target_type, "range": selected_ability.range}

func prompt_select_space() -> void:
	play_dialog("Select a space!", false)

func cancel_select_target() -> void:
	selected_ability = {}

func on_select_invalid_target() -> void:
	play_dialog("Not a valid target!", false)
		
func on_use_item(item_index: int) -> void:
	cursor.disable()
	var success = current_player.use_action(2)
	if success:
		var item = current_player.items.pop_at(item_index) # expensive on large arrays
		update_ui()
		
		add_event({"type": EventType.DIALOG, "text": str(current_player.char_name, " used " + item.name + "!"), "duration": dialog_duration, "emitter": current_player})
		current_player.items_equipped.append(item)
		current_player.populate_buffs_array()
		add_event({"type": EventType.DIALOG, "text": item.effect_description, "duration": dialog_duration, "emitter": current_player})
		increment_event_queue()
	else:
		prompt_action_points_insufficient()

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

func perform_enemy_turn() -> void:
	var targets: Array
	
	for player in players:
		if player.alliance == GameData.Alliance.HERO:
			targets.append(player)
	
	var target = select_target(targets)
	var enemy_ability = get_enemy_ability()
	
	add_event({"type": EventType.DIALOG, "text": current_player.char_name + " used " + enemy_ability.name + "!", "duration": dialog_duration, "emitter": current_player})
	
	var success = current_player.check_success(enemy_ability)
	if success:
		var damage_event = current_player.calculate_attack_dmg(enemy_ability)
		
		if target.guardian:
			add_event({"type": EventType.DIALOG, "text": target.char_name + " was protected!", "duration": dialog_duration, "emitter": current_player})
			
			var next_target = target.guardian
			target = next_target
		
		add_event({"type": EventType.ABILITY, "target": target, "damage_event": damage_event, "duration": selected_ability.animation.duration, "emitter": current_player, "animation": enemy_ability.animation.name})
		
		for effect in selected_ability.effects:
			build_effect_event(target, effect)
	else:
		add_event({"type": EventType.DIALOG, "text": "But it missed!", "duration": dialog_duration, "emitter": current_player})
				
	end_turn()

func select_target(targets: Array) -> Character:
	var random = randi() % targets.size()
	return targets[random]
	
func get_enemy_ability() -> Dictionary:
	var ability_index = randi() % current_player.abilities.size()
	var ability = current_player.abilities[ability_index]
	selected_ability = ability
	return ability
	
func on_movement(next_coords: Array) -> void:
	cursor.disable()
	var success = current_player.use_action(1)
	if success:
		ap_display.update_action_points(1)
		add_event({"type": EventType.MOVEMENT, "target": current_player, "next_position": next_coords[0], "duration": dialog_duration})
		add_event({"type": EventType.DIALOG, "text": current_player.char_name + " changed places!", "duration": dialog_duration})
		
		if current_player.guardian:
			current_player.set_guardian(null)
			add_event({"type": EventType.DIALOG, "text": current_player.char_name + " is no longer protected!", "duration": dialog_duration})
			
		increment_event_queue()
	else:
		prompt_action_points_insufficient()
		
func on_guard() -> void:
	cursor.disable()
	var guard_targets: Array
	var guard_pos = current_player.grid_position
	
	for pos in battle_grid.current_grid:
		if pos.x < guard_pos.x && pos.y == guard_pos.y:
			guard_targets.append(battle_grid.current_grid[pos])
	
	if !guard_targets.is_empty():
		for target in guard_targets:
			target.set_guardian(current_player)
	
	add_event({"type": EventType.DIALOG, "text": current_player.char_name + " used guard!", "duration": dialog_duration})

	for target in guard_targets:
		add_event({"type": EventType.GUARD, "target": target, "duration": 0.7, "animation": "Reinforce"})
	
	increment_event_queue()

func on_target_death(target: Character) -> void:
	if target.alliance == Data.Alliance.HERO:
		for player in players:
			if player.alliance == Data.Alliance.HERO:
				player.set_guardian(null)
				
	battle_grid.current_grid.erase(target.grid_position)
	players = players.filter(func(p): return p.char_name != target.char_name)
	event_queue = event_queue.filter(func(e): return !e.has("emitter") || e.emitter.char_name != target.char_name || e.has("target") && e.target.char_name != target.char_name) # make sure this works
	turn_queue = turn_queue.filter(func(c): return c.character.char_name != target.char_name)
	add_event({"type": EventType.DIALOG, "text": target.char_name + " died!", "duration": dialog_duration})
	add_event({"type": EventType.DEATH, "target": target, "duration": 0})
	
func resolve_item_effect() -> float:
	var buff = current_player.buffs.get(selected_ability.damage.type, 0) + 1
	return buff
		
func end_turn() -> void:
	cursor.disable()
	
	var effect_name = current_player.end_turn()
	if effect_name:
		add_event({"type": EventType.DIALOG, "text": current_player.char_name + " is no longer " + effect_name + "!", "duration": dialog_duration})
		
	add_event({"type": EventType.END_TURN, "duration": 0})
	increment_event_queue()

func check_valid_targets(target_cells: Array, check_movement: bool = false) -> bool:
	var valid_targets: Array[Vector2i]
	var occupied_cells = battle_grid.current_grid.keys()
	
	if check_movement && occupied_cells.has(target_cells[0]):
		return false
	elif check_movement:
		return true
		
	for cell in occupied_cells:
		if selected_ability.target_type == GameData.TargetType.ENEMY:
			if cell.x > 3: # if global grid width is constant, will always be '3'
				valid_targets.append(cell)
		elif selected_ability.target_type == GameData.TargetType.HERO:
			if cell.x < 4:
				valid_targets.append(cell)
				
	var is_valid_target: bool = false
	for cell in target_cells:
		if valid_targets.has(cell):
			is_valid_target = true
	return is_valid_target

func build_characters() -> void:
	var pc = pc_scene.instantiate()
	var pc_abilities = ["Clobber", "Heat Ray", "Screen Flash"]
	var pc_items = ["Extra Rock", "Extra Paper", "Sharpener"]
	pc.init("PC", Data.Alliance.HERO, pc.get_node("CharSprite"), pc.get_node("CharHealth"), 300, pc_abilities, Vector2i(2, 0), pc_items) # init props will be accessed from somewhere
	set_position_by_grid_coords(pc)
	pc.is_player = true
	add_child(pc)
	players.append(pc)
	
	var runt = runt_scene.instantiate()
	var runt_abilities = ["Ripjaw", "Reinforce", "Acid Cloud", "Ramming Strike"]
	var runt_items = ["Extra Rock", "Extra Paper", "Sharpener"]
	runt.init("Runt", Data.Alliance.HERO, runt.get_node("CharSprite"), runt.get_node("CharHealth"), 300, runt_abilities, Vector2i(3, 0), runt_items) # init props will be accessed from somewhere
	set_position_by_grid_coords(runt)
	add_child(runt)
	players.append(runt)
	runt.flip_sprite()
	
	var norman = norman_scene.instantiate()
	var norman_abilities = ["Clobber"]
	norman.init("Norman", Data.Alliance.ENEMY, norman.get_node("CharSprite"), norman.get_node("CharHealth"), 300, norman_abilities, Vector2i(5, 0)) # init props will be accessed from somewhere
	set_position_by_grid_coords(norman)
	add_child(norman)
	players.append(norman)
	
	var thumper = thumper_scene.instantiate()
	var thumper_abilities = ["Clobber", "Ripjaw"]
	thumper.init("Thumper", Data.Alliance.ENEMY, thumper.get_node("CharSprite"), thumper.get_node("CharHealth"), 300, thumper_abilities, Vector2i(6, 0)) # init props will be accessed from somewhere
	set_position_by_grid_coords(thumper)
	add_child(thumper)
	thumper.flip_sprite()
	players.append(thumper)
	
	var mandrake = mandrake_scene.instantiate()
	var mandrake_abilities = ["Sonic Pulse", "Ripjaw"]
	mandrake.init("Mandrake", GameData.Alliance.ENEMY, mandrake.get_node("CharSprite"), mandrake.get_node("CharHealth"), 300, mandrake_abilities, Vector2i(6, 2)) # init props will be accessed from somewhere
	set_position_by_grid_coords(mandrake)
	add_child(mandrake)
	mandrake.flip_sprite()
	players.append(mandrake)
	
	var pilypile = pilypile_scene.instantiate()
	var pilypile_abilities = ["Bulk Inversion", "Ripjaw", "Acid Cloud"]
	pilypile.init("Pilypile", GameData.Alliance.HERO, pilypile.get_node("CharSprite"), pilypile.get_node("CharHealth"), 300, pilypile_abilities, Vector2i(3, 2)) # init props will be accessed from somewhere
	set_position_by_grid_coords(pilypile)
	add_child(pilypile)
	mandrake.flip_sprite()
	players.append(pilypile)
			
func populate_grid() -> void:
	for player in players:
		battle_grid.set_object_at_grid_position(player)
	
#func set_grid_cells() -> Vector2i:
	# will create grid shape for the batlle
	#return Vector2i(8, 4)
	
func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
	
func get_current_player() -> Node:
	return current_player
	
#func get_grid_info() -> Dictionary:
	#return {"current_grid": battle_grid.current_grid, "grid_size": set_grid_cells()}
	
func set_position_by_grid_coords(character: Character) -> void:
	var coords = character.grid_position
	var x_pos = 192 + (coords.x * 128) # const grid_span_x = 128, const grid_offset_x = 192
	var y_pos = 390 + (coords.y * -100)
	character.position = Vector2i(x_pos, y_pos)

func set_turn_order() -> void:
	var positions: Array
	for player in players:
		var position_value = 100 / (float(player.current_attributes[Data.Attributes.MOBILITY] + 10))
		for i in range(20):
			positions.append({"character": player, "position_value": position_value * i})

	positions.sort_custom(func(playerA, playerB): return playerA.position_value < playerB.position_value)

	turn_queue.append_array(positions)
	
func increment_turn_queue() -> void:
	var mobility_changed = check_mobility_change()
	if mobility_changed || turn_queue.size() < 30:
		set_turn_order()
	var next_player = turn_queue.pop_front().character
	current_player = next_player
		
func check_mobility_change() -> bool:
	var has_changed: bool
	for player in players:
		if player.mobility_changed == true:
			has_changed = true
	if has_changed:
		return true
	else:
		return false

func prompt_action_points_insufficient() -> void:
	play_dialog("AP is too low!", false)
	cursor.enable()
	
func update_ui() -> void:
	if current_player.alliance == GameData.Alliance.HERO:	
		char_name_label.text = current_player.name
		update_display_health()
		ap_display.set_action_points(current_player.action_points)
		
		if current_player.items.is_empty():
			current_player.items.append({"name": "Empty", "menu_description": "You have no items"})

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

func update_display_health() -> void:
	health_display.max_value = current_player.health_bar.max_value
	health_display.value = current_player.health_bar.value
				
func initialize_battle() -> void:
	dialog = dialog_box[0]
	get_kapow()
	build_characters()
	populate_grid()
	increment_turn_queue()
	ap_display.initialize_ap_display()
	update_ui()
	
func get_kapow() -> Node:
	var kapow = kapow_scene.instantiate()
	self.add_child(kapow)
	return kapow
