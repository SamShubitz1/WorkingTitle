extends Area2D

@onready var npc: BaseNPC = get_parent()

var player_is_connected = false
var player: Area2D

func _ready():
	self.area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D):
	if area.name != "MyPlayer":
		return
	player = area
	if !player_is_connected:
		var player_controller = area.get_parent()
		player_controller.player_position_updated.connect(set_is_aggro)
		player_is_connected = true

func set_is_aggro(args):
	if self.overlaps_area(player):
		npc.set_aggro_mode(true)
	else:
		npc.set_aggro_mode(false)
