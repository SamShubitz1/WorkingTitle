extends BaseObject

class_name BaseRusty

func _ready() -> void:
	super._ready()
	var rusty_name = dialog_tree.name
	if PlayerFlags.flags.has(rusty_name + "_powered"):
		sprite.play("powered")
	
func _on_power_up() -> void:
	dialog_box.close()
	game_controller.play_transition()
	await get_tree().create_timer(0.5).timeout
	sprite.play("powered")

func start_dialog() -> void:
	if has_alt_greeting:
		PlayerFlags.flags[self.name + "_greeted"] = true
	
	var updated_tree = update_tree()
	var dialog_scene = load("res://Scenes/World/dialog_box.tscn")
	dialog_box = dialog_scene.instantiate()
	
	dialog_box.open_box.connect(game_controller._enter_dialog_mode)
	dialog_box.close_box.connect(game_controller._exit_dialog_mode)
	dialog_box.rusty_powered.connect(_on_power_up)
	
	game_controller.get_node("UI").add_child(dialog_box)
	dialog_box.set_tree(updated_tree)
