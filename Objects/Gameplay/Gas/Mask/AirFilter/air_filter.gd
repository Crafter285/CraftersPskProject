extends RigidBody3D

@onready var hand_grab: HandGrab = $HandGrab

func collect():
	hand_grab.release_grabbed()
	
	Grabpack.hud.gas_mask.recharge()
	Grabpack.sound_manager.collect()
	queue_free()

func _on_basic_interaction_player_interacted() -> void:
	collect()
func _on_hand_grab_let_go(_hand: bool) -> void:
	collect()
