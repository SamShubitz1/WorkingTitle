extends Area2D

@onready var game_controller = get_tree().current_scene

func _ready():
	self.area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area.name == "MyPlayer" && get_parent().battle_ready == true:
		game_controller.switch_to_scene(Data.Scenes.BATTLE, {"data": get_parent()})
