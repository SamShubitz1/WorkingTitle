extends Node2D

#TODO @onready var Title_Scene_File =
@onready var Overworld_Scene_File = "res://Scenes/Main/overworld.tscn"
@onready var Battle_Scene_File = "res://Scenes/Battle/battle.tscn"

#TODO @onready var Title_Scene_Node: Node =
#@onready var Overworld_Scene_Node: Node = get_tree().get_root().find_node("Overworld")
#@onready var Battle_Scene_Node: Node = get_tree().get_root().find_node("node_name")

var foo = "bar"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


# load new scene
func load_new_scene(scene, object: Node) -> void:
	get_tree().change_scene_to_file(scene)
	return

# load new battle scene from file
func load_battle_scene(object: Node) -> void:
	load_new_scene(Battle_Scene_File, object)
	#switch_to_battle_scene()
	return

# load new overworld scene from file
func load_overworld_scene() -> void:
	load_new_scene(Overworld_Scene_File, null)
	return

# switch to battle scene node
func switch_to_battle_scene() -> void:
	# check for existing battle scene node in tree
		# create new node if not found

	# pause / unload current scene (overworld)

	# unpause / load battle scene

	# update GameController state for mode tracking

	return

# switch to overworld scene node
#TODO

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
