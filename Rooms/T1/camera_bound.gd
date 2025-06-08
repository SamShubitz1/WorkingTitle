extends Area2D

func get_updated_camera_bounds():
	var rect = get_child(0).shape.get_rect()
	var global_center = self.global_position
	print(" global center " , global_center, " rect size ", rect , " bound name ", self.name)
	return {"left": global_center.x, "right": global_center.x + rect.size.x, "top": global_center.y, "bottom": global_center.y + rect.size.y}
