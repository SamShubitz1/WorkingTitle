extends Area2D

class_name ReturnArea

@onready var npc: BaseNPC = get_parent()

func _ready() -> void:
	set_range_limits()

func set_range_limits():
	var rect = get_child(0).shape.get_rect()
	var global_center = self.global_position
	npc.set_range_limits({"left": global_center.x, "right": global_center.x + rect.size.x, "top": global_center.y, "bottom": global_center.y + rect.size.y})
