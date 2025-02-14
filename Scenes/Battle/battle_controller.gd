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
	]}
var enemy_info: Dictionary = {"name": "Norman", "max_health": 80, "abilities": ["Rock","Paper","Scissors"]}
var attacks: Dictionary = {"Rock": {"damage": 20}, "Paper": {"damage": 20}, "Scissors": {"damage": 20}}
var initial_dialog: Dictionary = {"text": "A wild man appears!"}

enum EventType {
	DIALOG,
	ATTACK,
	ITEM,
	DEATH
}

# The idea is that ultimately each event object will have a type, maybe a class
# So we make a new Dialog, Item, or Attack event to be passed into the event queue
# right now events are just dictionaries with a type: EventType property
func _ready() -> void:
	player_health.max_value = character_info["max_health"]
	enemy_health.max_value = enemy_info["max_health"]
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
	
func on_attack(player_attack) -> void:
	handle_dialog({"text": "Player used " + player_attack + "!"})
	
	var attack = attacks[player_attack]
	var enemy_attack = get_enemy_attack()
	
	add_event({"type": EventType.DIALOG, "text": "Enemy used " + enemy_attack + "!"})
	
	var result = calculate_attack_dmg(player_attack, enemy_attack)
	if result:
		add_event({"type": EventType.ATTACK, "target": result.target, "damage": result.damage})
	
func calculate_attack_dmg(player_attack: String, enemy_attack: String):
	if player_attack == "Rock":
		match enemy_attack:
			"Rock":
				add_event({"type": EventType.DIALOG, "text": "Stalemate!"})
			"Paper":
				return {"target": "player", "damage": attacks[enemy_attack].damage}
			"Scissors":
				return {"target": "enemy", "damage": attacks[player_attack].damage}
	elif player_attack == "Paper":
		match enemy_attack:
			"Rock":
				return {"target": "enemy", "damage": attacks[player_attack].damage}
			"Paper":
				add_event({"type": EventType.DIALOG, "text": "Stalemate!"})
			"Scissors":
				return {"target": "player", "damage": attacks[enemy_attack].damage}
	elif player_attack == "Scissors":
		match enemy_attack:
			"Rock":
				return {"target": "player", "damage": attacks[enemy_attack].damage}
			"Paper":
				return {"target": "enemy", "damage": attacks[player_attack].damage}
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
