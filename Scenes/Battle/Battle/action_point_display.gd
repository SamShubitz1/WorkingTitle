extends Control

var ap_orb_off = preload("res://Scenes/Battle/Menu/Action_Point_Orb_OFF.png")
var ap_orb_on = preload("res://Scenes/Battle/Menu/Action_Point_Orb_ON.png")

var max_count = 5
var current_count: int
var ap_orbs: Array

func initialize_ap_display() -> void:
	for i in max_count:
		var ap_orb = build_ap_orb()
		self.add_child(ap_orb)
		ap_orbs.append(ap_orb)

func update_action_points(cost: int) -> void:
	current_count -= cost
	update_ui()
	
func set_action_points(count: int) -> void:
	current_count = count
	update_ui()

func update_ui() -> void:
	for i in max_count:
		if i < current_count:
			ap_orbs[i].texture = ap_orb_on
		else:
			ap_orbs[i].texture = ap_orb_off

func build_ap_orb() -> TextureRect:
	var ap_orb = TextureRect.new()
	ap_orb.z_index = 2
	ap_orb.size_flags_horizontal = SIZE_EXPAND_FILL
	ap_orb.size_flags_vertical = SIZE_EXPAND_FILL
	return ap_orb
