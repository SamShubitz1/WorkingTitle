extends Node2D

#TODO @onready var TitleScene =
@onready var Overworld_Scene = "res://Scenes/Main/overworld.tscn"
@onready var Battle_Scene = "res://Scenes/Battle/battle.tscn"

var foo = "bar"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# load new scene
func load_new_scene(scene) -> void:
	get_tree().change_scene_to_file(scene)
	return
