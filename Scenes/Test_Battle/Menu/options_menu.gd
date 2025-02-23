extends BaseMenu

@onready var menu_cursor = $"../Cursor"
@onready var menu_buttons = $"Menu".get_children().slice(1)

func _ready() -> void:
	init(menu_buttons, menu_cursor)
