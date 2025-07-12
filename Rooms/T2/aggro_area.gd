extends Area2D

class_name BaseAggroArea

@onready var npc: BaseNPC = get_parent()

var player_is_connected = false
var player: PlayerChar

func _ready(): 
	self.area_exited.connect(_on_area_exited)
	self.area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area.name != "MyPlayer":
		return

	if !player_is_connected:
		player = area
		var player_controller = player.get_parent()
		player_controller.player_position_updated.connect(_on_player_movement)
		player_is_connected = true
	
func _on_player_movement(player_coords: Vector2i) -> void:
	npc.set_player_coords(player_coords)
	
	if self.overlaps_area(player):
		npc.set_aggro_mode(true)

func _on_area_exited(area: Area2D) -> void:
	if area.name != "MyPlayer":
		return
	npc.set_aggro_mode(false)
