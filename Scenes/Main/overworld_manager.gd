extends Node2D

var default_player_pos = null

func _ready() -> void:
	$PlayerController.init(default_player_pos)
	
func set_default_player_pos(pos: Vector2) -> void:
	default_player_pos = pos
