extends Area2D

class_name CameraBoundArea

func get_updated_limits():
	var rect = get_child(0).shape.get_rect()
	var global_center = self.global_position
	return {"left": global_center.x, "right": global_center.x + rect.size.x, "top": global_center.y, "bottom": global_center.y + rect.size.y}
