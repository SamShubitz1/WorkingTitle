extends BaseMenu

@onready var menu_cursor = $"../Cursor"
@onready var enemy = $"../../Enemy"

func _ready() -> void:
	var enemies = [enemy]
	init(enemies, menu_cursor)
	set_scroll_size(enemies.size())
