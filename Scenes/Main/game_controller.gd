extends Node2D

@onready var map_controller = find_child("MapController", true)
@onready var player: PlayerClass = self.get_node("/root/MainScene/Overworld/PlayerController/MyPlayer")

var overworld_cam #not sure if needed
var battle_cam #same

var battle_res = "res://Scenes/Battle/Battle/battle_scene.tscn"
var overworld_res = "res://Scenes/Main/overworld.tscn"
var current_scene

func _ready() -> void:
	var overworld_scene = load(overworld_res)
	var overworld = overworld_scene.instantiate()
	add_child(overworld)
	current_scene = overworld

#func load_next_scene(next_scene) -> void:
	#if current_scene != next_scene:
		#get_tree().change_scene_to_packed(next_scene)
		#current_scene = next_scene

#func load_battle_scene() -> void:
	#var battle_scene = battle_scene_preload.instantiate()
	#load_next_scene(battle_scene)
#
#func load_overworld_scene() -> void:
	#var overworld_scene = overworld_scene_preload.instantiate()
	#load_next_scene(overworld_scene)

#func switch_to_battle_scene_file() -> void:
	#get_tree().change_scene_to_file(battle_scene)

func switch_to_battle_scene() -> void:
	var battle_scene = load(battle_res)
	var battle = battle_scene.instantiate()
		
	#battle_cam = battle_scene.get_node("BattleCamera")
	#battle_cam.make_current()

	current_scene.queue_free()
	add_child(battle)
	current_scene = battle
#
#func switch_to_overworld_scene_file() -> void:
	#get_tree().change_scene_to_file(overworld_scene)

func switch_to_overworld_scene() -> void:
	var overworld_scene = load(overworld_res)
	var overworld = overworld_scene.instantiate()
	
	#var overworld_cam = overworld.get_node("PlayerController/MyPlayer/OverworldCamera")
	#overworld_cam.make_current()

	current_scene.queue_free()
	add_child(overworld)
	current_scene = overworld

# pause target node / sub-scene
func set_pause_subtree(root: Node, pause: bool) -> void:
	var process_setters = ["set_process",
	"set_physics_process",
	"set_process_input",
	"set_process_unhandled_input",
	"set_process_unhandled_key_input",
	"set_process_shortcut_input",]

	for setter in process_setters:
		root.propagate_call(setter, [!pause])

func get_map_controller():
	print_tree()
	if map_controller == null:
		print("map controller is null")
	if player == null:
		print("Player is null")
	return map_controller

enum Scenes {
	OVERWORLD,
	BATTLE
}
