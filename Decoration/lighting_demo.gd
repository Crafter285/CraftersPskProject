extends Node3D

@onready var level_animation: AnimationPlayer = $LevelAnimation
@onready var decorated_level_cave: Node = $DecoratedLevelCAVE
@onready var wither_anim: AnimationPlayer = $IndoorArea/Monster/Wither/AnimationPlayer
@onready var wither_cutseen: Node3D = $IndoorArea/Monster/Wither
@onready var gate_3: StaticBody3D = $TransitionZone/Gate3
@onready var wither: CharacterBody3D = $IndoorArea/Monster/MonsterAI

func _ready() -> void:
	decorated_level_cave.queue_free()
	Game.tutorial("Hold [Q] For Hand Wheel | Use Mouse Scroll Wheel For Quick Swap.")

func _on_hand_scanner_left_scan_success() -> void:
	Grabpack.right_disable()
func _on_hand_scanner_left_2_scan_success() -> void:
	Grabpack.right_enable()

func _on_hand_item_collected() -> void:
	Grabpack.player.flashlight_togglable = true
	Game.tutorial("Press [F] to toggle flashlight")

func _on_power_receiver_2_powered() -> void:
	level_animation.play("fencedooropen")
func _on_hand_scanner_omni_scan_success() -> void:
	level_animation.play("fence2dooropen")

func _on_event_trigger_triggered() -> void:
	wither_anim.play("SpawnAnimation")
	wither_cutseen.show()
	await wither_anim.animation_finished
	wither_cutseen.queue_free()
	gate_3.opengate()
	wither.set_state(3)
	
