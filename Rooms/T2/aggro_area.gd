extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	self.area_entered.connect(_on_area_entered)
	self.area_exited.connect(_on_area_exited)
func _on_area_entered(area: Area2D):
	if area.name == "MyPlayer":
		get_parent().set_aggro_mode(true)
		print("TRUE")
	
func _on_area_exited(area: Area2D):
	if area.name == "MyPlayer":
		get_parent().set_aggro_mode(false)
		print("FALSE")
