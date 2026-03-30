extends Node3D

@onready var animation_player = $AnimationPlayer
@onready var spawn = $Spawn
@onready var shoot = $Shoot
@onready var flare_counter = $Skeleton3D/FlareCounter
@onready var fail = $Fail
@onready var counter = $Skeleton3D/Counter

var flares_count: int = 5
var max_flares: int = 5

const FLARE = preload("res://Objects/VFX/Flare/flareball.tscn")

var frame_colors: Array[Color] = [Color.RED, Color.RED, Color.RED, Color.RED, Color.ORANGE, Color.ORANGE, Color.YELLOW, Color.LIME, Color.GREEN]

func _on_hand_signal_connector_hand_used():
	if animation_player.is_playing():
		return
	if flares_count < 1:
		fail.play()
		return
	animation_player.play("shoot")
	
	var new_flare = FLARE.instantiate()
	get_tree().get_root().add_child(new_flare)
	new_flare.global_position = spawn.global_position
	new_flare.linear_velocity = -Grabpack.player.camera.get_global_transform().basis.z * 20.0
	shoot.play()
	flare_counter.visible = true
	flare_counter.play("Recharge")
	flares_count -= 1
	counter.text = str(flares_count)

func _on_flare_counter_animation_finished():
	flares_count += 1
	counter.text = str(flares_count)
	if flares_count < max_flares:
		flare_counter.visible = true
		flare_counter.play("Recharge")
	else:
		flare_counter.visible = false

func _on_flare_counter_frame_changed() -> void:
	flare_counter.modulate = frame_colors[flare_counter.frame]
