extends Node

@onready var dialog_box = $"../DialogBox/Dialog"
@onready var player_health = $"../BattleMenu/MainMenu/Menu/CharPanel/Health"
@onready var enemy_health = $"../Enemy/EnemyHealth"
@onready var cursor = $"../BattleMenu/Cursor"

var event_queue: Array = []

var character_info: Dictionary = {"name": "Deeno", "max_health": 100, "abilities": [
	{"name":"Rock", "description": "A rock based attack"},
	{"name": "Paper", "description": "A paper based attack"},
	{"name": "Scissors", "description": "A scissors based attack"}
	], "items": ["Extra Rock", "Sharpener", "Extra Paper"], "items_equipped": []}
var enemy_info: Dictionary = {"name": "Norman", "max_health": 80, "abilities": ["Rock","Paper","Scissors"]}
var attacks: Dictionary = {"Rock": {"type": "Rock", "damage": 20}, "Paper": {"type": "Paper", "damage": 20}, "Scissors": {"type": "Scissors", "damage": 20}}
var items: Dictionary = {"Extra Rock": {"id": 0, "multiplier": .2}, "Sharpener": {"id": 1, "multiplier": .2}, "Extra Paper": {"id": 2, "multiplier": .2}}
var initial_dialog: Dictionary = {"text": "A wild man appears!"}

enum EventType {
	DIALOG,
	ATTACK,
	DEATH
}

func _ready() -> void:
	player_health.max_value = character_info["max_health"]
	enemy_health.max_value = enemy_info["max_health"]
	handle_dialog(initial_dialog)

#The idea is that each event object will be a class instance, we make a new Dialog, Item, or Attack event to be passed into the event queue. Right now, events are just dictionaries with a type: EventType property
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
			
func handle_dialog(event: Dictionary) -> void:
	dialog_box.text = event.text
	
func handle_attack(event: Dictionary) -> void:
		if event.target == "enemy":
			enemy_health.value -= event.damage
			handle_dialog({"text": "Enemy took " + str(event.damage) + " damage!"})
		elif event.target == "player":
			player_health.value -= event.damage
			handle_dialog({"text": "Player took " + str(event.damage) + " damage!"})
		check_death()
	
func on_attack(player_attack: String) -> void:
	handle_dialog({"text": "Player used " + player_attack + "!"})
	var attack = attacks[player_attack]
	var enemy_attack = get_enemy_attack()
	
	add_event({"type": EventType.DIALOG, "text": "Enemy used " + enemy_attack + "!"})
	
	var result = calculate_attack_dmg(player_attack, enemy_attack)
	if result:
		add_event({"type": EventType.ATTACK, "target": result.target, "damage": result.damage})
	
func on_use_item(item_name: String) -> void:
	handle_dialog({"text": "Player used " + item_name + "!"})
	var item = items[item_name]
	character_info.items_equipped.append(item)

func calculate_attack_dmg(player_attack: String, enemy_attack: String):
	if player_attack == "Rock":
		match enemy_attack:
			"Rock":
				add_event({"type": EventType.DIALOG, "text": "Stalemate!"})
			"Paper":
				return {"target": "player", "damage": attacks[enemy_attack].damage}
			"Scissors":
				var damage = attacks[player_attack].damage
				if items["Extra Rock"] in character_info.items_equipped:
					print(character_info.items_equipped)
					print(items["Extra Rock"])
					damage += damage * items["Extra Rock"].multiplier
				return {"target": "enemy", "damage": damage}
	elif player_attack == "Paper":
		match enemy_attack:
			"Rock":
				var damage = attacks[player_attack].damage
				if items["Extra Paper"] in character_info.items_equipped:
					damage += damage * items["Extra Paper"].multiplier
				return {"target": "enemy", "damage": damage}
			"Paper":
				add_event({"type": EventType.DIALOG, "text": "Stalemate!"})
			"Scissors":
				return {"target": "player", "damage": attacks[enemy_attack].damage}
	elif player_attack == "Scissors":
		match enemy_attack:
			"Rock":
				return {"target": "player", "damage": attacks[enemy_attack].damage}
			"Paper":
				var damage = attacks[player_attack].damage
				if items["Sharpener"] in character_info.items_equipped:
					damage += damage * items["Sharpener"].multiplier
				return {"target": "enemy", "damage": damage}
			"Scissors":
				add_event({"type": EventType.DIALOG, "text": "Stalemate!"})
	
func get_enemy_attack() -> String:
	var attack_index = randi() % enemy_info["abilities"].size()
	var attack = enemy_info["abilities"][attack_index]
	return attack

func check_death() -> void:
	if player_health.value <= 0 || enemy_health.value <= 0:
		var dead_name
		if player_health.value == 0:
			dead_name = "Player"
		else:
			dead_name = "Enemy"
		add_event({"type": EventType.DIALOG, "text": dead_name + " died!"})
		add_event({"type": EventType.DEATH})
			
			
func handle_death() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main/mainscene.tscn")
