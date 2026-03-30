extends Camera3D
class_name SecurityCamera

signal obstacle_openned

@export var proximity = true
@export var proximity_distance = 12.0
@export var play_puzzle_complete_sound = false
enum sound_version {
	puzzle_complete,
	grabpack_jingle,
}
@export var complete_sound: sound_version = sound_version.puzzle_complete

var openned = false

func _ready() -> void:
	add_to_group("WatchCamera")

func open_obstacle():
	if not openned:
		if global_position.distance_to(Grabpack.player.global_position) < proximity_distance or not proximity:
			
			emit_signal("obstacle_openned")
			if play_puzzle_complete_sound:
				if complete_sound == 0:
					Grabpack.sound_manager.puzzle_sfx()
				else:
					Grabpack.sound_manager.jingle_sfx()
			openned = true
		else:
			Game.tooltip("CAMERA IS TOO FAR AWAY")
	else:
		Game.tooltip("THE OBSTACLE IS ALREADY OPENNED")
