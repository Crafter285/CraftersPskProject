extends AudioStreamPlayer

func quicksfx(sound: AudioStream, volume: float = 0.0, position: Vector3 = Vector3.ZERO):
	var new_sound: QuickSFX = QuickSFX.new()
	new_sound.stream = sound
	
	add_child(new_sound)
	
	new_sound.volume_db = volume
	new_sound.global_position = position
	new_sound.play()
func quick_local_sfx(sound: AudioStream, volume: float = 0.0):
	var new_sound: QuickSFXNoDir = QuickSFXNoDir.new()
	new_sound.stream = sound
	
	add_child(new_sound)
	
	new_sound.volume_db = volume
	new_sound.play()
