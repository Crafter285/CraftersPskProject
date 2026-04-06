extends Node3D

@export_group("Settings")
@export var hand_scene: PackedScene
@export var hand_preview_object: Node3D
@export var disabled: bool = false
@export var play_collect_sound: bool = true
@export var hand_index: int = -1
@export var replace_hand_at_index: bool = false
@export var start_open: bool = false

@export_group("Puzzle Settings")
@export var Needs_Puzzle: bool = false
@export var puzzle: NodePath
@export var use_open_signal: bool = true
@export var enable_signal: String = ""
@export var use_close_signal: bool = true
@export var disable_signal: String = ""

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var locked: bool = false

signal opened
signal closed
signal hand_collected

var stage: int = 0

func _ready() -> void:
	if disabled == true:
		$Area3D.queue_free()
	if Needs_Puzzle == true:
		$Area3D.queue_free()
	$BasicInteraction.hide()
	if start_open == true:
		animation_player.play("Open_Start")
	if Needs_Puzzle == true:
		var puzzle_node = get_node(puzzle)
		if use_open_signal:
			puzzle_node.connect(enable_signal, open)
		if use_close_signal:
			puzzle_node.connect(disable_signal, close)
	animation_player.play("RESET")

func open() -> void:
	if locked == false:
		stage = 1
		animation_player.play("Open")
		$BasicInteraction.show()
		$BasicInteraction/CollisionShape3D.show()
		$BasicInteraction/InteractionIndicator.show()
		opened.emit()

func close() -> void:
	if locked == false:
		stage = 0
		animation_player.play("Close")
		$BasicInteraction.hide()
		$BasicInteraction/CollisionShape3D.hide()
		$BasicInteraction/InteractionIndicator.hide()
		closed.emit()

func _on_basic_interaction_player_interacted() -> void:
	if not (stage == 1 and not animation_player.is_playing()): return
	collect()

func collect():
	if locked == false:
		$BasicInteraction.queue_free()
		$BasicInteraction/CollisionShape3D.queue_free()
		$BasicInteraction/InteractionIndicator.queue_free()
		animation_player.play("Close")
		locked = true
		hand_preview_object.queue_free()
		if play_collect_sound:
			Grabpack.player.sound_manager.collect()
		if hand_index < 0: Grabpack.add_hand(hand_scene)
		else: 
			if replace_hand_at_index: Grabpack.remove_hand_index(hand_index, false, false)
			Grabpack.add_hand(hand_scene, hand_index)
		hand_collected.emit()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if not body.is_in_group("Player"):
		return
	if Needs_Puzzle == false:
		open()


func _on_area_3d_body_exited(body: Node3D) -> void:
	if not body.is_in_group("Player"):
		return
	if Needs_Puzzle == false:
		close()
