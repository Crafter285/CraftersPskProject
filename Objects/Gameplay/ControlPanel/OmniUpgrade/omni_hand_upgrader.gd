extends Node3D

var stage: int = 0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var basic_interaction: BasicInteraction = $BasicInteraction
@onready var basic_interaction_2: BasicInteraction = $BasicInteraction2
@onready var omnihandmesh: Skeleton3D = $SM_ConsolOmniHand_Upgrader2/SM_ConsolOmniHand_Pedestal/Skeleton3DE
@onready var hand_preview: MeshInstance3D = $SM_ConsolOmniHand_Upgrader/SM_ConsolOmniHand_Pedestal/SK_GrabpackHand_002

var hand_idx: int = 0

func _on_keycard_reader_inserted() -> void:
	stage = 1
	animation_player.play("Part1")
	await animation_player.animation_finished
	basic_interaction.visible = true
	hand_preview.visible = true

func _on_basic_interaction_player_interacted() -> void:
	if not (stage == 1 and not animation_player.is_playing()): return
	if not Grabpack.has_hand("RedHand"): return
	hand_preview.visible = false
	basic_interaction.visible = false
	hand_idx = Grabpack.get_hand_idx("RedHand")
	Grabpack.remove_hand("RedHand")
	stage = 2
	animation_player.play("Part2")
	basic_interaction.queue_free()
	await animation_player.animation_finished
	basic_interaction_2.visible = true

func _on_basic_interaction_2_player_interacted() -> void:
	if not (stage == 2 and not animation_player.is_playing()): return
	basic_interaction_2.visible = false
	stage = 3
	omnihandmesh.queue_free()
	animation_player.play("Part3")
	Grabpack.sound_manager.collect()
	Grabpack.remove_hand_index(hand_idx, false)
	Grabpack.add_hand(preload("res://Player/Grabpack/Hands/omni.tscn"), hand_idx)
