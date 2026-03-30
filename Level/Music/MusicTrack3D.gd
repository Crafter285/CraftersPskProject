extends AudioStreamPlayer3D
##Enable looping on the Stream values audiostream to loop the main track.
class_name MusicTrack3D

@export var InTrack: AudioStream
@export var OutTrack: AudioStream
var main_track: AudioStream

@export var fade_speed: float = 3.0
var target_volume: float = 1.0
var fadingIn: bool = false
var fadingOut: bool = false

func _ready() -> void:
	target_volume = volume_db
	main_track = stream

func _process(delta: float) -> void:
	if fadingIn:
		if volume_db < -30.0:
			volume_db += fade_speed*3.0*delta
			return
		volume_db += fade_speed*delta
		if volume_db > target_volume:
			volume_db = target_volume
			fadingIn = false
	if fadingOut:
		volume_db -= fade_speed*delta
		if volume_db < -30.0:
			fade_speed *= 1.0+fade_speed*delta
			if volume_db < -70.0:
				fadingOut = false
				stop()

func In():
	stream = InTrack
	play()
	connect("finished", Callable(_inFinished))
func _inFinished():
	stream = main_track
	play()
	disconnect("finished", Callable(_inFinished))
func Out():
	stop()
	stream = OutTrack
	play()
	fadeIn()

##Fades in your track.
func fadeIn(speed: float = fade_speed, from_pos: float = 0.0):
	play(from_pos)
	volume_db = -80.0
	fadingIn = true
##Fades out your track.
func fadeOut(speed: float = fade_speed):
	fade_speed = speed
	fadingOut = true
