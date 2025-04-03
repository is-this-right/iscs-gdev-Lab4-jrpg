extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
class character:
	var stats = {
		"health" : 100,
		"max_health" : 100,
		"defense" :30,
		"attack" : 20,
	}
	
	var effects = {
		"weakened" : {"strength" : -10, "duration": 0},
		"shattered" : {"strength" : -30, "duration": 0},
		"mark" : {"strength" : 0, "duration": 0},
	}
	
	func takeDamage(incoming_dmg:int):
		# incoming damage is calculated by the system
		# computation how much damage is received given the effects
		var apparentDamage = incoming_dmg-(stats['defense']-(effects['shattered']['strength']*(effects['shattered']['duration']>0)))
		stats['health']-= apparentDamage
		return apparentDamage
	
	func consumeDurationEffect(): # done at the end of a round
		for key in effects.keys():
			if effects[key]['duration'] > 0:
				effects[key]['duration'] -= 1
	
		
