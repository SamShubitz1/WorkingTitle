extends BaseMenu

class_name BaseLog

var entries: Array
var slots: Array

var scroll_index: int = 1

func navigate_forward() -> void:
	if is_active:
		scroll_down()
	
func navigate_backward() -> void:
	if is_active:
		scroll_up()
		
func activate() -> void:
	self.show_menu()
	is_active = true
	cursor.hide()
	menu.modulate = Color(1.5, 1.5, 1.5)
	
func disactivate() -> void:
	is_active = false
	cursor.show()
	menu.modulate = Color(1, 1, 1)
	
func scroll_up():
	if scroll_index > 1:
		scroll_index -= 1
	for i in range(slots.size()):
		if scroll_index < entries.size() - (slots.size() - 1):
			slots[i].text = entries[(entries.size()) - (scroll_index + i)]
	slots[0].modulate = Color(1, 1, 0)

func scroll_down():
	if scroll_index + (slots.size() - 1) < entries.size():
		scroll_index += 1
	for i in range(slots.size()):
		if scroll_index + (slots.size() - 1) <= entries.size():
			slots[i].text = entries[entries.size() - (scroll_index + i)]	
	slots[0].modulate = Color(1, 1, 0)
	
func init(log: Node, log_slots: Array, menu_cursor: BaseCursor) -> void:
	self.menu = log
	self.slots = log_slots
	self.cursor = menu_cursor
	
func set_entries(log_entries: Array) -> void:
	self.entries = log_entries

func update_selected_button(index = null) -> void:
	pass # override base menu behavior

		
	
