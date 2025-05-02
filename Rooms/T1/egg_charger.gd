extends BaseNPC

var egg_flags = [{"name": "egg_charger_greeted", "value": true}]

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	flags = egg_flags
