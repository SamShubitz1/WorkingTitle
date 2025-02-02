extends TextureRect

var offset = Vector2i(110, 11)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func move_cursor(position: Vector2i) -> void:
	self.position = position + offset
