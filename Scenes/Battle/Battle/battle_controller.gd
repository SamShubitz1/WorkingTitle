extends Node

@onready var animation_player = $"../BattleMenuControl/DialogBox/AnimationPlayer"
@onready var dialog_box = $"../BattleMenuControl/DialogBox/BattleLog".get_children().slice(1)
@onready var player_health_bar = $"../BattleMenuControl/MainMenu/Menu/CharPanel/Health"
@onready var enemy_health_bar = $"../Enemy/EnemyHealth"
@onready var player = $"../Player"
@onready var enemy = $"../Enemy"
@onready var cursor = $"../BattleMenuControl/Cursor"
#@export var enemy_scene: PackedScene

var battle_grid: BaseGrid = BaseGrid.new()
var grid_size: Vector2i = Vector2i(2, 4)
var valid_target: String

var event_queue: Array = []
var filter_list: Array = [] # will be used to filter out obsolete events

var initial_dialog: String = "A wild man appears!"
var battle_log: Array = []
var dialog: Label
var scroll_index: int = 0
var manual_increment: bool = false

var dialog_duration: float = 0.7
var attack_duration: float = 0.7

var selected_attack: Dictionary

enum EventType {
	DIALOG,
	ATTACK,
	DEATH,
	RETREAT,
}

func _ready() -> void:
	#battle_grid.init(set_grid_cells())
	populate_grid()
	player_health_bar.max_value = player.max_health
	enemy_health_bar.max_value = enemy.max_health
	dialog = dialog_box[0]
	play_dialog(initial_dialog)

func add_event(event) -> void:
	event_queue.append(event)
	
func clear_queue() -> void:
	event_queue.clear()

func increment_queue() -> void:
	var event = event_queue.pop_front()
	if event:
		match event.type:
			EventType.DIALOG:
				handle_dialog(event)
			EventType.ATTACK:
				handle_attack(event)
			EventType.DEATH:
				handle_death()
			EventType.RETREAT:
				handle_retreat()
				
		if event.has("duration") && not manual_increment:
			await wait(event.duration)
			
			if event_queue.is_empty():
				cursor.enable()
				play_dialog("Player turn!")
				
			increment_queue() # can recursively call itself :O
		else:
			manual_increment = true
	else:
		manual_increment = false
		cursor.enable()
			
func handle_dialog(event: Dictionary) -> void:
	dialog.text = event.text
	battle_log.append(event.text)
	update_dialog_queue()
	
func play_dialog(text: String) -> void: # redundant function, could be used to filter messages from battle log
	dialog.text = text
	battle_log.append(text)
	update_dialog_queue()
	
func update_dialog_queue() -> void:
	for i in range(dialog_box.size()):
		if i < battle_log.size():
			dialog_box[i].text = battle_log[(battle_log.size() - 1) - i]
	dialog_box[0].modulate = Color(1, 1, 0)
	if battle_log.size() > 20:
		battle_log = battle_log.slice(1)
	scroll_index = 1
	
func handle_attack(event: Dictionary) -> void:
		if event.target == "enemy":
			enemy_health_bar.value -= event.damage
			play_dialog("Enemy took " + str(event.damage) + " damage!")
		elif event.target == "player":
			player_health_bar.value -= event.damage
			play_dialog("Player took " + str(event.damage) + " damage!")
		check_death()
		
func on_use_attack(target: String) -> void:
	cursor.disable()
	var damage = calculate_attack_dmg()
	add_event({"type": EventType.DIALOG, "text": "Player used " + selected_attack.name + "!", "duration": dialog_duration})
	add_event({"type": EventType.ATTACK, "target": target, "damage": damage, "duration": attack_duration})
	perform_enemy_attack()
	increment_queue()

func prompt_select_target(attack_name: String) -> void:
	var player_attack = GameData.abilities[attack_name]
	selected_attack = player_attack
	if player_attack.target == "enemy":
		valid_target = "enemy"
	elif player_attack.target == "ally":
		valid_target = "player"
	play_dialog("Select a target!")
	
func cancel_select_target() -> void:
	selected_attack = {}
		
func on_use_item(item_index: int) -> void:
	cursor.disable()
	var item = player.items.pop_at(item_index) # expensive on large arrays
	if player.items.is_empty():
		player.items.append({"name": "Empty", "menu_description": "You have no items"})
	add_event({"type": EventType.DIALOG, "text": "Player used " + item.name + "!", "duration": dialog_duration})
	player.items_equipped.append(item)
	player.populate_buffs_array()
	add_event({"type": EventType.DIALOG, "text": item.effect_description, "duration": dialog_duration})
	perform_enemy_attack()
	increment_queue()

func on_try_retreat() -> void:
	cursor.disable()
	add_event({"type": EventType.DIALOG, "text": "Player retreats!", "duration": dialog_duration})
	var success: bool = player_health_bar.value > randi() % int(enemy_health_bar.value)
	if success:
		add_event({"type": EventType.DIALOG, "text": "Got away safely!"})
		add_event({"type": EventType.RETREAT})
	else:
		add_event({"type": EventType.DIALOG, "text": "But it failed!", "duration": dialog_duration})
		perform_enemy_attack()
	increment_queue()

func calculate_attack_dmg() -> int:
	var damage: int = selected_attack.damage
	var multiplier: float = resolve_status_effects()
	damage *= multiplier
	return damage
	
func perform_enemy_attack() -> void:
	var enemy_attack = get_enemy_attack()
	add_event({"type": EventType.DIALOG, "text": "Enemy used " + enemy_attack.name + "!", "duration": dialog_duration})
	add_event({"type": EventType.ATTACK, "target": "player", "damage": enemy_attack.damage, "duration": attack_duration})
	
func get_enemy_attack() -> Dictionary:
	var attack_index = randi() % enemy.abilities.size()
	var attack = enemy.abilities[attack_index]
	return attack

func check_death() -> void:
	if player_health_bar.value <= 0 || enemy_health_bar.value <= 0:
		var dead_name
		if player_health_bar.value == 0:
			dead_name = "You"
		else:
			dead_name = "Enemy"
		clear_queue()
		add_event({"type": EventType.DIALOG, "text": dead_name + " died!"})
		add_event({"type": EventType.DEATH})
		increment_queue()
		
func resolve_status_effects() -> float:
	var buff = player.buffs.get(selected_attack.type, 0) + 1
	return buff
	
func handle_retreat() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main/mainscene.tscn")
		
func handle_death() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main/mainscene.tscn")
	
func populate_grid() -> void:
	battle_grid.set_object_at_grid_position(Vector2i(0,3), player)
	battle_grid.set_object_at_grid_position(Vector2i(0,4), enemy)
	
func set_grid_cells() -> Vector2i:
	# will create grid shape for the batlle
	return Vector2i(8, 2)
	
func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
	
func get_player_info() -> Dictionary:
	return {"name": player.name, "abilities": player.abilities, "items": player.items}
	
func get_grid_info() -> Dictionary:
	return {"current_grid": battle_grid.current_grid, "grid_size": set_grid_cells()}
