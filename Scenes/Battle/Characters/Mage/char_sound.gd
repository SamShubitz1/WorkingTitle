extends AudioStreamPlayer

func play_sound(char_name, action: Data.SoundAction):
	var action_string: String
	
	match action:
		Data.SoundAction.START:
			action_string = "Start"
		Data.SoundAction.ATTACK:
			action_string = "Attack"
		Data.SoundAction.DEATH:
			action_string = "Death"
			
	var variant: String
	if action == Data.SoundAction.DEATH:
		variant = "A1"
	else:
		var index = randi() % 2
		var variants = ["A1","A2"]
		variant = variants[index]
		
	var sound_string = char_name + action_string + variant
	set_stream(load(Data.sounds[sound_string]))
	play()
