extends VBoxContainer

@onready var attack_button = $Battle_Menu/Options/Attack
@onready var move_button = $Battle_Menu/Options/Move
@onready var items_button = $Battle_Menu/Options/Items
@onready var status_button = $Battle_Menu/Options/Status
@onready var retreat_button = $Battle_Menu/Options/Retreat

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass
	
func on_attack() -> void:
	pass	
	
func on_retreat() -> void:
	get_tree().quit()
