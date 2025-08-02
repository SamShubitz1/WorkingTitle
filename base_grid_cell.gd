extends Node

class_name BaseGridCell

var character: Character = null
var terrain: Data.BattleTerrain = Data.BattleTerrain.NONE

func set_terrain(next_terrain) -> void:
	terrain = next_terrain
