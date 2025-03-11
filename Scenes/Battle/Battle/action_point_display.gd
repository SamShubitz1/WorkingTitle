extends Control

var orb_off = preload("res://Scenes/Battle/Menu/Action_Point_Orb_OFF.png")
var orb_on = preload("res://Scenes/Battle/Menu/Action_Point_Orb_ON.png")

var max_count = 5
var current_count: int
var orbs: Array

func initialize_ap_display() -> void:
	for i in max_count:
		var orb = build_orb()
		self.add_child(orb)
		orbs.append(orb)

func update_action_points(cost: int) -> void:
	current_count -= cost
	update_ui()
	
func set_action_points(count: int) -> void:
	current_count = count
	update_ui()

func update_ui() -> void:
	for i in max_count:
		if i < current_count:
			orbs[i].texture = orb_on
		else:
			orbs[i].texture = orb_off

func build_orb() -> TextureRect:
	var orb = TextureRect.new()
	orb.z_index = 2
	orb.size_flags_horizontal = SIZE_EXPAND_FILL
	orb.size_flags_vertical = SIZE_EXPAND_FILL
	
	return orb
