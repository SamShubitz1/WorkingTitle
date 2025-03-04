extends Node

class_name Event

enum EventType {
	DIALOG,
	ATTACK,
	ITEM,
	RETREAT,
	DEATH
}

var type: EventType
var publisher: Character = null
var target: Character = null
var text: String = ""
var duration: float = 0.0
