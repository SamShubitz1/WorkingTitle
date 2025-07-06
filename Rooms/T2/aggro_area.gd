extends Area2D

@onready var npc: BaseNPC = get_parent()

var player_is_connected = false

func _ready():
	self.area_entered.connect(_on_area_entered)
	self.area_exited.connect(_on_area_exited)
	
func _on_area_entered(area: Area2D):
	if area.name != "MyPlayer":
		return
	
	if !player_is_connected:
		var player_controller = area.get_parent()
		player_controller.player_position_updated.connect(npc.set_player_coords)
		player_is_connected = true
	
	npc.set_aggro_mode(true)
	
func _on_area_exited(area: Area2D):
	if area.name == "MyPlayer":
		npc.set_aggro_mode(false)
