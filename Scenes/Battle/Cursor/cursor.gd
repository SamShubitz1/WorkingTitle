extends TextureRect

var offset = Vector2i(110, 11)

func move_cursor(position: Vector2i) -> void:
	self.position = position + offset
