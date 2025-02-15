extends Node

@onready var dialog_box = $"../DialogBox/Dialog"
@onready var player_health = $"../BattleMenu/MainMenu/Menu/CharPanel/Health"
@onready var enemy_health = $"../Enemy/EnemyHealth"
@onready var player = $"../Player"
@onready var enemy = $"../Enemy"
@onready var cursor = $"../BattleMenu/Cursor"

var event_queue: Array = []
var filter_list: Array = [] # when character dies their published events will be filtered during increment queue

var selected_attack: Dictionary

var initial_dialog: Dictionary = {"text": "A wild man appears!"}

enum EventType {
	DIALOG,
	ATTACK,
	DEATH,
	RETREAT,
}

func _ready() -> void:
	player_health.max_value = player.max_health
	enemy_health.max_value = enemy.max_health
	handle_dialog(initial_dialog)

func add_event(event) -> void:
	event_queue.append(event)

func increment_queue() -> void:
	var event = event_queue.pop_front()
	match event.type:
		EventType.DIALOG:
			handle_dialog(event)
		EventType.ATTACK:
			handle_attack(event)
		EventType.DEATH:
			handle_death()
		EventType.RETREAT:
			handle_retreat()
	if event_queue.size() == 0:
				cursor.enable()
			
func handle_dialog(event: Dictionary) -> void:
	dialog_box.text = event.text
	
func handle_attack(event: Dictionary) -> void:
		if event.target == "enemy":
			enemy_health.value -= event.damage
		elif event.target == "player":
			player_health.value -= event.damage
		check_death()

func on_use_attack(target: String) -> void:
	cursor.disable()
	handle_dialog({"text": "Player used " + selected_attack.name + "!"})
	var damage = calculate_attack_dmg()
	add_event({"type": EventType.ATTACK, "target": target, "damage": damage})
	add_event({"type": EventType.DIALOG, "text": "Enemy took " + str(damage) + " damage!"})
	perform_enemy_attack()
	
func prompt_select_target(player_attack: Dictionary) -> void:
	selected_attack = player_attack
	handle_dialog({"text": "Select a target!"})
	
func cancel_select_target() -> void:
	selected_attack = {}
	handle_dialog({"text": "Select an ability!"})
	
func on_use_item(item: Dictionary) -> void:
	cursor.disable()
	handle_dialog({"text": "Player used " + item.name + "!"})
	player.items_equipped.append(item)
	player.populate_buffs_array()
	add_event({"type": EventType.DIALOG, "text": item.effect_description})
	perform_enemy_attack()

func on_try_retreat() -> void:
	cursor.disable()
	handle_dialog({"text": "Player retreats!"})
	var success: bool = player_health.value > randi() % int(enemy_health.value)
	if success:
		clear_queue()
		add_event({"type": EventType.DIALOG, "text": "Got away safely!"})
		add_event({"type": EventType.RETREAT})
	else:
		add_event({"type": EventType.DIALOG, "text": "But it failed!"})
		perform_enemy_attack()

func calculate_attack_dmg() -> int:
	var damage: int = selected_attack.damage
	var multiplier: float = resolve_status_effects()
	damage *= multiplier #if damage ends in '0' it will stay an int
	return damage
	
func perform_enemy_attack() -> void:
	var enemy_attack = get_enemy_attack()
	add_event({"type": EventType.DIALOG, "text": "Enemy used " + enemy_attack.name + "!"})
	add_event({"type": EventType.ATTACK, "target": "player", "damage": enemy_attack.damage})
	add_event({"type": EventType.DIALOG, "text": "Player took " + str(enemy_attack.damage) + " damage!"})
	
func get_enemy_attack() -> Dictionary:
	var attack_index = randi() % enemy.abilities.size()
	var attack = enemy.abilities[attack_index]
	return attack

func check_death() -> void:
	if player_health.value <= 0 || enemy_health.value <= 0:
		var dead_name
		if player_health.value == 0:
			dead_name = "Player"
		else:
			dead_name = "Enemy"
		clear_queue()
		add_event({"type": EventType.DIALOG, "text": dead_name + " died!"})
		add_event({"type": EventType.DEATH})
		
func resolve_status_effects() -> float:
	var buff = player.buffs.get(selected_attack.type, 0) + 1
	return buff
	
func clear_queue() -> void:
	event_queue.clear()
	
func handle_retreat() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main/mainscene.tscn")
		
func handle_death() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main/mainscene.tscn")
