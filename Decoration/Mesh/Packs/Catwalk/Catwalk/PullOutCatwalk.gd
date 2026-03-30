extends Node3D

@onready var hand_grab: HandGrab = $catwalk_base/GrabHandle/HandGrab
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var pull_sound: AudioStreamPlayer3D = $PullSound

var pulled: bool = false

func _on_hand_grab_pulled(hand: bool) -> void:
	pulled = true
	hand_grab.enabled = false
	animation_player.play("pullout")
	pull_sound.play()
	
	await Game.delay(0.5)
	
	hand_grab.release_grabbed()
