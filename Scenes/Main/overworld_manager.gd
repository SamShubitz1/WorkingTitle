extends Node2D

var default_player_pos = null

func _ready() -> void:
	$PlayerController.init(default_player_pos)
	load_pause_menu()
	
func set_default_player_pos(pos: Vector2) -> void:
	default_player_pos = pos

func load_pause_menu() -> void:
	var pause_menu_scene = load("res://Scenes/StartMenu/start_menu.tscn")
	var pause_menu = pause_menu_scene.instantiate()
	add_child(pause_menu)

	pause_menu.anchor_left = 0.5
	pause_menu.anchor_top = 0.5
	pause_menu.anchor_right = 0.5
	pause_menu.anchor_bottom = 0.5
 
	# Define desired width and height
	var width = 300
	var height = 200

	# Use offsets to center the menu
	pause_menu.offset_left = -width / 2
	pause_menu.offset_top = -height / 2
	pause_menu.offset_right = width / 2
	pause_menu.offset_bottom = height / 2
	
	pause_menu.close()
