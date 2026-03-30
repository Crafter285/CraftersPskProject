
extends AudioStreamPlayer
##Enable looping on the Stream values audiostream to loop the main track.
class_name MusicTrack

@export var InTrack: AudioStream
@export var OutTrack: AudioStream
var main_track: AudioStream

@export var fade_speed: float = 3.0
var target_volume: float = 1.0
var fadingIn: bool = false
var fadingOut: bool = false
var fadingSpeed: float = 5.0

func _ready() -> void:
	target_volume = volume_db
	main_track = stream

func _process(delta: float) -> void:
	if fadingIn:
		if volume_db < -30.0:
			volume_db += fade_speed*6.0*delta
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
	if not fadingIn and not fadingOut:
		if not is_equal_approx(volume_db, target_volume):
			volume_db = move_toward(volume_db, target_volume, fadingSpeed*delta)

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
func lower_to(volume: float, speed: float = fadingSpeed):
	target_volume = volume
	fadingSpeed = speed

##Fades in your track.
func instantIn(from_pos: float = 0.0):
	play(from_pos)
	volume_db = target_volume
	fadingIn = false
	fadingOut = false
##Fades in your track.
func fadeIn(speed: float = fade_speed, from_pos: float = 0.0):
	play(from_pos)
	volume_db = -50.0
	fadingIn = true
	fade_speed = speed
##Fades out your track.
func fadeOut(speed: float = fade_speed):
	fade_speed = speed
	fadingOut = true

func is_fading():
	if fadingIn or fadingOut: return true
	else: return false
