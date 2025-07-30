extends Node2D

@onready var fade_to_black = $FadeToBlackCanvas

var battle_res = "res://Scenes/Battle/Battle/battle_scene.tscn"
var overworld_res = "res://Scenes/Main/overworld.tscn"
var current_scene
var is_loading = false

func _ready() -> void:
	var overworld_scene = load(overworld_res)
	var overworld = overworld_scene.instantiate()
	add_child(overworld)
	current_scene = overworld

func switch_to_scene(next_scene: Data.Scenes, data: Dictionary = {}):
	if is_loading:
		return
	else:
		is_loading = true

	var resource = get_scene_resource(next_scene)
	var loaded_scene = load(resource)
	var scene = loaded_scene.instantiate()
	
	if !data.is_empty():
		scene.init(data)
		
	play_transition()
	await get_tree().create_timer(0.5).timeout
	
	current_scene.queue_free()
	add_child(scene)
	
	current_scene = scene
	is_loading = false

func play_transition() -> void:
	fade_to_black.play_transition()

func get_scene_resource(scene: Data.Scenes) -> String:
	var resource: String
	match scene:
		Data.Scenes.OVERWORLD:
			resource = overworld_res
		Data.Scenes.BATTLE:
			resource = battle_res
		_:
			resource = ""
	return resource

# pause target node / sub-scene
#func set_pause_subtree(root: Node, pause: bool) -> void:
	#var process_setters = ["set_process",
	#"set_physics_process",
	#"set_process_input",
	#"set_process_unhandled_input",
	#"set_process_unhandled_key_input",
	#"set_process_shortcut_input",]
#
	#for setter in process_setters:
		#root.propagate_call(setter, [!pause])
