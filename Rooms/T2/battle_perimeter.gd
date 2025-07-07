extends Area2D

class_name BaseBattleArea

@onready var game_controller = get_tree().current_scene

func _ready():
	self.area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area.name == "MyPlayer" && get_parent().battle_ready == true:
		var player_controller = area.get_parent()
		player_controller.enter_battle_scene(self)
