extends AudioStreamPlayer3D
class_name AudioStreamPlayerInOut3D
@export var in_sound: AudioStream
@export var out_sound: AudioStream
@export var loop: AudioStream

func In():
	stream = in_sound
	play()
	await finished
	stream = loop
	play()
func Out():
	stream = out_sound
	play()
