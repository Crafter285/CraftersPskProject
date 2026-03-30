extends Node3D

@onready var animation_player = $AnimationPlayer
@onready var spawn = $Spawn
@onready var shoot = $Shoot

const FLARE = preload("res://Objects/VFX/Flare/bullet.tscn")

var tim: float = 0.0

func _process(delta: float) -> void:
	if $GPUParticles3D3.emitting:
		tim += 1.0*delta
		if tim > 0.2:
			tim = 0.0
			$GPUParticles3D3.emitting = false
	
	if Input.is_action_just_pressed("reset"):
		Grabpack.player.get_node("Grabpack/Pack/ItemAnimation").play("ReloadGun")
		$Reload.play()
		animation_player.play("reload")

func _on_hand_signal_connector_hand_used():
	if animation_player.is_playing():
		return
	animation_player.play("shoot")
	
	var new_flare = FLARE.instantiate()
	get_tree().get_root().add_child(new_flare)
	new_flare.global_position = spawn.global_position
	new_flare.linear_velocity = -Grabpack.player.camera.get_global_transform().basis.z * 60.0
	shoot.play(0.42)
	
	Grabpack.player.camera.shake_camera(0.1, 12.0)
	
	$GPUParticles3D3.amount = 20
	$GPUParticles3D3.emitting = true
