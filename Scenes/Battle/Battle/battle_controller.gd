extends Node2D

@onready var ai_controller = $AiController
@onready var game_controller = get_tree().current_scene
@onready var dialog_box = $"../BattleMenu/DialogBox/BattleLog".get_children().slice(1)
@onready var cursor = $"../BattleMenu/Cursor"
@onready var health_display = $"../BattleMenu/MainMenu/Menu/CharPanel/StatusBars/Health"
@onready var energy_display = $"../BattleMenu/MainMenu/Menu/CharPanel/StatusBars/Energy"
@onready var ap_display = $"../BattleMenu/Descriptions/Labels/ActionPointDisplay"
@onready var reticle = $Reticle
@onready var char_name_label = $"../BattleMenu/MainMenu/Menu/CharPanel/NameLabel"
@onready var items_node = $"../BattleMenu/ItemsMenu"
@onready var abilities_node = $"../BattleMenu/AbilitiesMenu"

var kapow_scene = preload("res://Scenes/Battle/Battle/kapow_scene.tscn")
var gawkingstick_scene = preload("res://Scenes/Battle/Characters/Norman/norman.tscn")
var thumper_scene = preload("res://Scenes/Battle/Characters/Thumper/thumper.tscn")
var mage_scene = preload("res://Scenes/Battle/Characters/Mage/mage.tscn")
var runt_scene = preload("res://Scenes/Battle/Characters/Runt/runt.tscn")
var mandrake_scene = preload("res://Scenes/Battle/Characters/Mandrake/mandrake.tscn")
var pilypile_scene = preload("res://Scenes/Battle/Characters/Pilypile/pilypile.tscn")

var players: Array[Character]
var current_player: Character
var battle_id = 0

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
		update_health_display()
		if event.has("animation"):
			var kapow = get_kapow()
			
			var position: Vector2i
			if event.animation.origin == Data.AnimOrigin.OTHER:
				position = event.target.position
			elif event.animation.origin == Data.AnimOrigin.SELF:
				position = current_player.position
			
			current_player.sound.play_sound(current_player.char_name, Data.SoundAction.ATTACK)
				
			kapow.start(position, event.target.z_index, event.animation.name, event.duration)
	
		current_player.sprite.attack(event.duration)
		
		if event.target.health_bar.value <= 0:
			on_target_death(event.target)
#
	elif event.has("effect"):
		event.target.resolve_effect(event.effect)
		play_dialog(event.target.char_name + " " + event.effect.dialog + "!", true)
		
		if event.has("effect_animation"):
			var position: Vector2i
			if event.effect_animation.origin == Data.AnimOrigin.OTHER:
				position = event.target.position
			elif event.effect_animation.origin == Data.AnimOrigin.SELF:
				position = current_player.position
			
			var effect_kapow = get_kapow()
			effect_kapow.start(position, event.target.z_index, event.effect_animation.name, event.duration)
			
			current_player.sprite.attack(event.duration)
			current_player.sound.play_sound(current_player.char_name, Data.SoundAction.ATTACK)
		
		if event.effect.property == Data.SpecialStat.AP:
			ap_display.set_action_points(current_player.action_points)
			
func handle_movement(event: Dictionary) -> void:
	var target = event.target
	battle_grid.update_grid_object(target, event.next_position)
	set_position_by_grid_coords(target)
	reticle.move(target.position)
	
func handle_guard(event: Dictionary) -> void:
	var target = event.target
	var current_kapow = get_kapow()
	current_kapow.start(event.target.position, event.target.z_index, event.animation, event.duration)
	play_dialog(target.char_name + " is protected!", true)

func handle_death(event) -> void:
	if event.target.is_player:
		game_controller.switch_to_overworld_scene()
	else:
		event.target.visible = false
		event.target.sound.play_sound(event.target.char_name, Data.SoundAction.DEATH)

func handle_end_turn() -> void:
	var effect_name = current_player.end_turn()
	if effect_name:
		add_event({"type": EventType.DIALOG, "text": current_player.char_name + " is no longer " + effect_name + "!", "duration": dialog_duration, "emitter": current_player})
		
	increment_turn_queue()
	add_event({"type": EventType.DIALOG, "text": current_player.char_name + "'s turn!", "duration": dialog_duration, "emitter": current_player})
	
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
	var energy_success = current_player.use_energy(selected_ability.energy_cost)
	if !energy_success:
		prompt_action_energy_insufficient()
		return
	update_energy_display()
	var cost = selected_ability.action_cost
	var ap_success = current_player.use_action(cost)
	if !ap_success:
		prompt_action_points_insufficient()
		return

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

func build_attack_event(target: Character) -> void:
	var damage_event = current_player.calculate_attack_dmg(selected_ability)
	
	if selected_ability.has("animation"):
		add_event({"type": EventType.ABILITY, "target": target, "damage_event": damage_event, "duration": selected_ability.animation.duration, "emitter": current_player, "animation": selected_ability.animation})
	else:
		add_event({"type": EventType.ABILITY, "target": target, "damage_event": damage_event, "duration": dialog_duration, "emitter": current_player})

func build_effect_event(target: Character, effect: Dictionary) -> void:
	var effect_target: Character

	if effect.target == Data.EffectTarget.OTHER:
		effect_target = target
	elif effect.target == Data.EffectTarget.SELF:
		effect_target = current_player
					#
	if effect.has("animation"):
		add_event({"type": EventType.ABILITY, "effect": effect, "target": effect_target, "duration": effect.animation.duration, "emitter": current_player, "effect_animation": effect.animation})
	else:
		add_event({"type": EventType.ABILITY, "effect": effect, "target": effect_target, "duration": dialog_duration, "emitter": current_player})

func prompt_select_target(ability_name: String) -> Dictionary:
	var target_cells = []
	var hero_ability = GameData.abilities[ability_name]
	selected_ability = hero_ability
	play_dialog("Select a target!", false)
	if hero_ability.shape == Data.AbilityShape.MELEE: #for melee attacks, battle controller passes valid targets to battle menu
		target_cells = battle_grid.get_melee_targets(Data.Alliance.HERO)
	return {"shape": hero_ability.shape, "target_type": selected_ability.target_type, "range": selected_ability.range, "origin": current_player.grid_position, "target_cells": target_cells}

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
	var enemy_turn = ai_controller.build_turn(current_player, players)
	
	for action in enemy_turn:
		match action.type:
			Data.EnemyAction.MOVE:
				add_event({"type": EventType.MOVEMENT, "target": current_player, "next_position": action.position, "duration": dialog_duration})
				add_event({"type": EventType.DIALOG, "text": current_player.char_name + " changed places!", "duration": dialog_duration})
				
			Data.EnemyAction.ABILITY:
				selected_ability = action.ability
				add_event({"type": EventType.DIALOG, "text": current_player.char_name + " used " + selected_ability.name + "!", "duration": dialog_duration, "emitter": current_player})
				
				var success = current_player.check_success(selected_ability)
				if !success:
					add_event({"type": EventType.DIALOG, "text": "But it missed!", "duration": dialog_duration, "emitter": current_player})
					end_turn()
					return
					
				for target in action.targets:
					if target.guardian:
						add_event({"type": EventType.DIALOG, "text": target.char_name + " was protected!", "duration": dialog_duration, "emitter": current_player})
						var next_target = target.guardian
						target = next_target
					if !selected_ability.damage.type == Data.DamageType.NONE:
						build_attack_event(target)
				
					for effect in selected_ability.effects:
						build_effect_event(target, effect)

	end_turn()
	
func on_movement(next_coords: Vector2i) -> void:
	cursor.disable()
	var success = current_player.use_action(1)
	if !success:
		prompt_action_points_insufficient()
		return
		
	ap_display.update_action_points(1)
	add_event({"type": EventType.MOVEMENT, "target": current_player, "next_position": next_coords, "duration": dialog_duration})
	add_event({"type": EventType.DIALOG, "text": current_player.char_name + " changed places!", "duration": dialog_duration})
	
	if current_player.guardian:
		current_player.set_guardian(null)
		add_event({"type": EventType.DIALOG, "text": current_player.char_name + " is no longer protected!", "duration": dialog_duration})
		
	if current_player.alliance == Data.Alliance.HERO:
		increment_event_queue()
	
	current_player.has_moved = true
		
func on_guard() -> void:
	cursor.disable()
	var success = current_player.use_action(1)
	if !success:
		prompt_action_points_insufficient()
		return
		
	ap_display.update_action_points(1)
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
	players = players.filter(func(p): return p.battle_id != target.battle_id)
	event_queue = event_queue.filter(func(e): return !e.has("emitter") || e.emitter.battle_id != target.battle_id || e.has("target") && e.target.battle_id != target.battle_id) # make sure this works
	turn_queue = turn_queue.filter(func(c): return c.character.battle_id != target.battle_id)
	add_event({"type": EventType.DIALOG, "text": target.char_name + " died!", "duration": dialog_duration})
	add_event({"type": EventType.DEATH, "target": target, "duration": 0})
	
func resolve_item_effect() -> float:
	var buff = current_player.buffs.get(selected_ability.damage.type, 0) + 1
	return buff
		
func end_turn() -> void:
	cursor.disable()
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
			if cell.x > 3: # (# of columns / 2) - 1
				valid_targets.append(cell)
		elif selected_ability.target_type == GameData.TargetType.HERO:
			if cell.x < 4:
				valid_targets.append(cell)
				
	var is_valid_target: bool = false
	for cell in target_cells:
		if valid_targets.has(cell):
			is_valid_target = true
			
	return is_valid_target
		
func get_players() -> void:
	var positions = get_enemies_by_position()
	for pos in positions:
		var next_enemy = build_character(positions[pos], Data.Alliance.ENEMY, pos)
		players.append(next_enemy)
	
	var mage = build_character("Mage", Data.Alliance.HERO, Vector2i(3,1))
	players.append(mage)
	var mandrake = build_character("Mandrake", Data.Alliance.HERO, Vector2i(2,2))
	players.append(mandrake)
	var pilypile = build_character("Pilypile", Data.Alliance.HERO, Vector2i(2,0))
	players.append(pilypile)
	
func get_enemies_by_position():
	var enemies = select_enemies()
	var occupied_cells: Array
	var positions: Dictionary
	for i in range(enemies.size()):
		while positions.size() < i + 1:
			var next_position = Vector2i(randi_range(4,7), randi_range(0,3)) # hard coded
			if next_position not in occupied_cells:
				positions[next_position] = enemies[i]
				occupied_cells.append(next_position)
	return positions

func select_enemies():
	var enemy_pool = ["Runt", "Pilypile", "Gawkingstick", "Thumper", "Mandrake"]
	var selected_enemies: Array
	var number_of_enemies = randi_range(2, 5)
	for i in range(number_of_enemies):
		var enemy_index = randi() % (enemy_pool.size() - 1)
		selected_enemies.append(enemy_pool[enemy_index])
	
	return selected_enemies
	
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
		for i in range(1, 15):
			positions.append({"character": player, "position_value": position_value * i})
	positions.sort_custom(func(playerA, playerB): return playerA.position_value < playerB.position_value)

	turn_queue.append_array(positions)
	
func increment_turn_queue() -> void:
	var mobility_changed = check_mobility_change()
	if mobility_changed || turn_queue.size() < 30:
		set_turn_order()
	var next_player = turn_queue.pop_front().character
	current_player = next_player
	reticle.move(current_player.position)
	current_player.start_turn()
	current_player.sound.play_sound(current_player.char_name, Data.SoundAction.START)
	
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

func prompt_action_energy_insufficient() -> void:
	play_dialog("Energy is too low!", false)
	cursor.enable()
	
func update_ui() -> void:
	if current_player.alliance == GameData.Alliance.HERO:	
		char_name_label.text = current_player.char_name
		update_health_display()
		update_energy_display()
		ap_display.set_action_points(current_player.action_points)
		
		if current_player.items.is_empty():
			current_player.items.append({"name": "Empty", "menu_description": "You have no items"})

		var abilities_buttons = abilities_node.get_child(0).get_children().slice(3)
		for i in range(abilities_buttons.size()):
			if i < current_player.current_abilities.size():
				abilities_buttons[i].text = current_player.current_abilities[i].name
			else:
				abilities_buttons[i].text = "???"

		var items_buttons = items_node.get_child(0).get_children().slice(3)
		for i in range(items_buttons.size()):
			if i < current_player.items.size():
				items_buttons[i].text = current_player.items[i].name
			else:
				items_buttons[i].text = "-"

func update_health_display() -> void:
	health_display.max_value = current_player.health_bar.max_value
	health_display.value = current_player.health_bar.value

func update_energy_display() -> void:
	energy_display.value = current_player.current_energy
	
func initialize_battle() -> void:
	dialog = dialog_box[0]
	
	get_players()
	battle_grid.populate_grid(players)
	increment_turn_queue()
	
	ap_display.initialize_ap_display()
	update_ui()
	
func get_kapow() -> Node:
	var kapow = kapow_scene.instantiate()
	self.add_child(kapow)
	return kapow
	
func build_character(name: String, char_alliance: Data.Alliance, position: Vector2i):
	var char_scene = load(GameData.characters[name].path)
	var char_info = GameData.characters[name]
	var char = char_scene.instantiate()
	char.init(battle_id, name, char_info.attributes, char_alliance, char.get_node("CharSprite"), char.get_node("CharSound"), char.get_node("CharHealth"), char_info["base energy"], char_info["base health"], char_info.abilities, position, char_info.role)
	add_child(char)
	set_position_by_grid_coords(char)
	battle_id += 1
	return char
