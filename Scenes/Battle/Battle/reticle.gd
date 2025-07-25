extends Sprite2D

var reticle_offset = Vector2i(0, 10)

func _ready() -> void:
	self.hide()
	self.z_index = 7
	
func move(next_position: Vector2i) -> void:
	self.show()
	self.position = next_position + reticle_offset
