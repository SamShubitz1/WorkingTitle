extends Node

class_name BaseGridCell

var character: Character = null
var terrain: Data.BattleTerrain = Data.BattleTerrain.NONE

func _init(initial_terrain) -> void:
	terrain = initial_terrain
