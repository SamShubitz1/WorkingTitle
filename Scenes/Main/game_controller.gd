extends Node2D

@onready var Map_Controller = self.get_node("/root/MainScene/Overworld/MapController")
@onready var Player: PlayerClass = self.get_node("/root/MainScene/Overworld/PlayerController/MyPlayer")
#@onready var Player_Camera = Player.Player_Camera

#TODO @onready var Title_Scene_File =
const Overworld_Scene_File = "res://Scenes/Main/overworld.tscn"
const Battle_Scene_File = "res://Scenes/Battle/Battle/battle_scene.tscn"

var overworld_cam_obj
var battle_cam_obj

#TODO @onready var Title_Scene_Node: Node =
#@onready var Overworld_Scene_Node: Node = get_tree().get_root().find_node("Overworld")
#@onready var Battle_Scene_Node: Node = get_tree().get_root().find_node("node_name")

var preloaded_scene_battle
var preloaded_scene_overworld
var current_scene_node

var imported_overworld_scene
var imported_battle_scene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	preloaded_scene_overworld = preload(Overworld_Scene_File)
	imported_overworld_scene = preloaded_scene_overworld.instantiate()
	get_node("/root/MainScene/").add_child(imported_overworld_scene)
	overworld_cam_obj = imported_overworld_scene.get_node("PlayerController/MyPlayer/OverworldCamera")

	preloaded_scene_battle = preload(Battle_Scene_File)
	#var imported_battle_scene = preloaded_scene_battle.instantiate()
	#get_node("/root/MainScene/").add_child(imported_battle_scene)
	#battle_cam_obj = imported_battle_scene.get_node("BattleCamera")
	#print("battlecam: " + str(battle_cam_obj))

	var tree = get_tree()
	var rootNode = tree.root
	var node = get_node("/root/MainScene/Overworld")
	current_scene_node = node

	pass # Replace with function body.

# load new scene
func load_new_scene(scene, object: Node) -> void:
	get_tree().change_scene_to_file(scene)
	return

# load new battle scene from file
func load_battle_scene(object: Node) -> void:
	#load_new_scene(Battle_Scene_File, object)
	switch_to_battle_scene()
	return

# load new overworld scene from file
func load_overworld_scene() -> void:
	load_new_scene(Overworld_Scene_File, null)
	return

func switch_to_battle_scene_file() -> void:
	get_tree().change_scene_to_file(Battle_Scene_File)
	return

# switch to battle scene node
func switch_to_battle_scene() -> void:
	var current_scene_node = get_node("/root/MainScene/Overworld")
	# check for existing battle scene node in tree

	var rootNode = get_tree().root
	var node = rootNode.find_child("battle")
	if (node):
		print_debug("found scene: " + str(node))
	else:
		# create new node if not found
		imported_battle_scene = preloaded_scene_battle.instantiate()
		get_node("/root/MainScene/").add_child(imported_battle_scene)
		battle_cam_obj = imported_battle_scene.get_node("BattleCamera")
		# hide overworld scene in tree
		current_scene_node.hide()
		# switch cameras
		battle_cam_obj.make_current()

	# pause / unload current scene (overworld)
	imported_overworld_scene.get_parent().remove_child(imported_overworld_scene)
	imported_overworld_scene.queue_free()
	imported_overworld_scene = null
	current_scene_node = null

	# update GameController state for mode tracking
	#TODO

	return

func switch_to_overworld_scene_file() -> void:
	get_tree().change_scene_to_file(Overworld_Scene_File)
	return

# switch to overworld scene node
func switch_to_overworld_scene() -> void:
	var current_scene_node = get_node("/root/MainScene/BattleScene")

	imported_overworld_scene = preloaded_scene_overworld.instantiate()
	get_node("/root/MainScene/").add_child(imported_overworld_scene)
	overworld_cam_obj = imported_overworld_scene.get_node("PlayerController/MyPlayer/OverworldCamera")
	print("overworldcam: " + str(overworld_cam_obj))

	current_scene_node.hide()

	overworld_cam_obj.make_current()

	imported_battle_scene.get_parent().remove_child(imported_battle_scene)
	imported_battle_scene.queue_free()
	imported_battle_scene = null
	current_scene_node = null
	return

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

	return

func get_map_controller():
	return Map_Controller
