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
var damage_event: DamageEvent
var emitter: Character = null

class DamageEvent:
	var damage: int
	var damage_type: Data.DamageType
	var effect: EffectEvent
		
class EffectEvent:
	var effect_type: Data.EffectTypes
	var effect_value: int
	var effect_target: Data.EffectTypes

func _init(event_params: Dictionary):
	self.type = event_params.get("type", null)
	self.text = event_params.get("text", null)
	self.duration = event_params.get("duration", null)
	self.target = event_params.get("target", null)
	self.damage_event = event_params.get("damage_event", null)
	self.emitter = event_params.get("event_params", null)
