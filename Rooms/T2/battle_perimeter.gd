extends Area2D

class_name BaseBattleArea

@onready var game_controller = get_tree().current_scene
@onready var npc = get_parent()

func _ready():
	self.area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area.name == "MyPlayer" && npc.battle_ready == true:
		var player_controller = area.get_parent()
		player_controller.enter_battle_scene(npc.battle_data)
