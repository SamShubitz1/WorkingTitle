extends BaseMenu

class_name BaseLog

var entries: Array
var slots: Array # Label/text nodes that will be populated with log entries

var scroll_index: int = 1

func init(log: Node, log_slots: Array, menu_cursor: BaseCursor, initial_button_position = null, log_entries: Array = []) -> void:
	self.menu = log
	self.slots = log_slots
	self.cursor = menu_cursor
	if log_entries:
		self.entries = log_entries
		for i in range(slots.size()):
			if scroll_index < entries.size() - (slots.size() - 1):
				slots[i].text = entries[(entries.size()) - (scroll_index + i)]

func navigate_forward(_e: InputEvent) -> void:
	if is_active:
		scroll_down()
	
func navigate_backward(_e: InputEvent) -> void:
	if is_active:
		scroll_up()
		
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
		
func activate() -> void:
	self.show_menu()
	is_active = true
	cursor.hide()
	menu.modulate = Color(1.5, 1.5, 1.5)
	
func disactivate() -> void:
	is_active = false
	cursor.show()
	menu.modulate = Color(1, 1, 1)
	scroll_index = 1
			
func get_current_entry() -> String:
	return slots[0].text
	
func get_selected_button() -> Button:
	return slots[0]

func update_selected_button() -> void:
	pass # override base menu behavior

func update_entries(next_entries: Array) -> void:
	entries = next_entries
