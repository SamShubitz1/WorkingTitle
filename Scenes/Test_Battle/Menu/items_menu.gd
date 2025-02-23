extends BaseMenu

@onready var menu_cursor = $"../Cursor"
@onready var menu_buttons = $"Menu".get_children().slice(3)
@onready var player = $"../../Player"

func _ready() -> void:
	init(menu_buttons, menu_cursor)
	set_scroll_size(player.items.size())
