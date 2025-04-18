extends Node2D

@onready var map_controller = find_child("MapController", true)
@onready var player: PlayerClass = self.get_node("/root/MainScene/Overworld/PlayerController/MyPlayer")

var overworld_cam #not sure if needed
var battle_cam #same

var battle_scene_preload = preload("res://Scenes/Battle/Battle/battle_scene.tscn")
var overworld_scene_preload = preload("res://Scenes/Main/overworld.tscn")
var current_scene

var overworld_scene
var battle_scene

func _ready() -> void:
	overworld_scene = overworld_scene_preload.instantiate()
	add_child(overworld_scene)
	current_scene = overworld_scene

func load_next_scene(next_scene) -> void:
	if current_scene != next_scene:
		get_tree().change_scene_to_file(next_scene)
		current_scene = next_scene

func load_battle_scene() -> void:
	if battle_scene == null:
		battle_scene = battle_scene_preload.instantiate()
	load_next_scene(battle_scene)

func load_overworld_scene() -> void:
	if overworld_scene == null:
		overworld_scene = overworld_scene_preload.instantiate()
	load_next_scene(overworld_scene)

#func switch_to_battle_scene_file() -> void:
	#get_tree().change_scene_to_file(battle_scene)

#func switch_to_battle_scene() -> void:
	#if current_scene == battle_scene:
		#return
		#
	#if battle_scene == null:
		#battle_scene = battle_scene_preload.instantiate()
		#add_child(battle_scene)
		
	#battle_cam = battle_scene.get_node("BattleCamera")
	#battle_cam.make_current()

	#overworld_scene.queue_free()
	#overworld_scene = null
	#current_scene = battle_scene
#
#func switch_to_overworld_scene_file() -> void:
	#get_tree().change_scene_to_file(overworld_scene)

#func switch_to_overworld_scene() -> void:
	#if current_scene == overworld_scene:
		#return
		#
	#if overworld_scene == null:
		#overworld_scene = overworld_scene_preload.instantiate()
		#add_child(overworld_scene)
		#
	#overworld_cam = overworld_scene.get_node("PlayerController/MyPlayer/OverworldCamera")
	#overworld_cam.make_current()
#
	#battle_scene.queue_free()
	#battle_scene = null
	#current_scene = overworld_scene

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
