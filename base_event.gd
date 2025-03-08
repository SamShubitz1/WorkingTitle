extends Node

class_name Event

enum EventType {
	DIALOG,
	ATTACK,
	MOVEMENT,
	DEATH,
	RETREAT,
	END_TURN
}

var type: EventType
var text: String = ""
var duration: float = 0.0
var target: Character = null
var emitter: Character = null

func _init()

func build_event() -> void:
	var event = Event.new()
	
