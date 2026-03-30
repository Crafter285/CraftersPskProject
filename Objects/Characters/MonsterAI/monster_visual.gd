extends Node3D
class_name MonsterVisual

@export var sound: MonsterSoundPack
@export var animation_player: AnimationPlayer = null
@export var idle_animation_name: String = ""
@export var idle_animation_speed: float = 1.0
@export var walk_animation_name: String = ""
@export var walk_animation_speed: float = 1.0
@export var run_animation_name: String = ""
@export var run_animation_speed: float = 1.5
@export var spawn_animation_name: String = ""
@export var spawn_animation_speed: float = 1.0
@export var jumpscare_animation_name: String = ""
@export var jumpscare_animation_speed: float = 1.0
@export var jumpscare_camera: Camera3D = null
@export var jumpscare_use_transition: bool = false
@export var jumpscare_transition_length: float = 0.2
var taunt_name: String = ""
var taunt_speed: float = 1.0

enum anims {
	idle,
	walk,
	run,
	jumpscare,
	taunt,
	spawn
}

func play_animation(anim_name: anims = anims.idle):
	if anim_name == anims.idle:
		if sound.idle_sounds.size() > 0: GlobalSound.quicksfx(sound.idle_sounds[randi_range(0, (sound.idle_sounds.size()-1))], 0.0, global_position)
		animation_player.play(idle_animation_name)
		animation_player.speed_scale = idle_animation_speed
	elif anim_name == anims.walk:
		if sound.idle_sounds.size() > 0: GlobalSound.quicksfx(sound.moving_sounds[randi_range(0, (sound.moving_sounds.size()-1))], 0.0, global_position)
		animation_player.play(walk_animation_name)
		animation_player.speed_scale = walk_animation_speed
	elif anim_name == anims.run:
		if sound.idle_sounds.size() > 0: GlobalSound.quicksfx(sound.moving_sounds[randi_range(0, (sound.moving_sounds.size()-1))], 0.0, global_position)
		animation_player.play(run_animation_name)
		animation_player.speed_scale = run_animation_speed
	elif anim_name == anims.jumpscare:
		animation_player.play(jumpscare_animation_name)
		animation_player.speed_scale = jumpscare_animation_speed
		if jumpscare_use_transition:
			CameraTransition.transition_camera(Grabpack.player.camera, jumpscare_camera, jumpscare_transition_length)
		else: jumpscare_camera.current = true
		GlobalSound.stream = sound.jumpscare_sound
		GlobalSound.play()
		await animation_player.animation_finished
		
		get_parent().jumpscare_finished.emit()
		if get_parent().death_screen_after_jumpscare: Grabpack.kill_player(true)
	elif anim_name == anims.taunt:
		animation_player.play(taunt_name)
		animation_player.speed_scale = taunt_speed
	elif anim_name == anims.spawn:
		animation_player.play(spawn_animation_name)
		animation_player.speed_scale = spawn_animation_speed
func step():
	GlobalSound.quicksfx(sound.footstep_sounds[randi_range(0, (sound.footstep_sounds.size()-1))], sound.footstep_volume,global_position)
