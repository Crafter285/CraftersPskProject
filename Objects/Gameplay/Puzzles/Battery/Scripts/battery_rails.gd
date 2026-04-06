extends Node3D

@export_group("Rail1")
@export var use_rail1: bool = true
@export var needs_puzzle: bool = true
@export var puzzle: Node
@export var use_on_signal: bool = true
@export var on_signal: String = ""
@export var use_off_signal: bool = true
@export var off_signal: String = ""
@export_group("Rail2")
@export var use_rail2: bool = true
@export var needs_puzzle_: bool = true
@export var puzzle_: Node
@export var use_on_signal_: bool = true
@export var on_signal_: String = ""
@export var use_off_signal_: bool = true
@export var off_signal_: String = ""

@onready var rail_1_animation_player: AnimationPlayer = $AnimationPlayer
@onready var rail_2_animation_player: AnimationPlayer = $AnimationPlayer2

var has_started1: bool = false
var has_started2: bool = false
var usable1: bool = false
var usable2: bool = false
var pulling1_f: bool = false
var pulling2_f: bool = false
var pulling1_b: bool = false
var pulling2_b: bool = false

signal rail1_complete
signal rail2_complete

func _ready() -> void:
	if needs_puzzle and puzzle != null:
		if use_on_signal and on_signal != "":
			puzzle.connect(on_signal, on1)
		if use_off_signal and off_signal != "":
			puzzle.connect(off_signal, off1)

	if needs_puzzle_ and puzzle_ != null:
		if use_on_signal_ and on_signal_ != "":
			puzzle_.connect(on_signal_, on2)
		if use_off_signal_ and off_signal_ != "":
			puzzle_.connect(off_signal_, off2)

	rail_1_animation_player.animation_finished.connect(_on_rail1_animation_finished)
	rail_2_animation_player.animation_finished.connect(_on_rail2_animation_finished)

	if use_rail1 == false:
		rail_1_animation_player.play("PosRight")
		await rail_1_animation_player.animation_finished
		rail_1_animation_player.speed_scale = 0.0

	if use_rail2 == false:
		rail_2_animation_player.play("PosRight")
		await rail_2_animation_player.animation_finished
		rail_2_animation_player.speed_scale = 0.0

func _on_rail1_animation_finished(anim_name: StringName) -> void:
	if rail_1_animation_player.speed_scale >= 0.0:
		rail1_complete.emit()

func _on_rail2_animation_finished(anim_name: StringName) -> void:
	if rail_2_animation_player.speed_scale >= 0.0:
		rail2_complete.emit()

func on1():
	usable1 = true

	if pulling1_f == true:
		rail_1_animation_player.speed_scale = 1.0

	if pulling1_b == true:
		rail_1_animation_player.speed_scale = -1.0

func off1():
	usable1 = false
	rail_1_animation_player.speed_scale = 0.0

func on2():
	usable2 = true

	if pulling2_f == true:
		rail_2_animation_player.speed_scale = 1.0

	if pulling2_b == true:
		rail_2_animation_player.speed_scale = -1.0

func off2():
	usable2 = false
	rail_2_animation_player.speed_scale = 0.0

func _on_hand_grab_pulled(hand: bool) -> void:
	if not use_rail1:
		return
	if not usable1:
		return
	if not has_started1:
		return
	if rail_1_animation_player.current_animation_position <= 0.0:
		return
	if not rail_1_animation_player.is_playing():
		rail_1_animation_player.play("StartLeft")
		rail_1_animation_player.seek(rail_1_animation_player.current_animation_length, true)
	rail_1_animation_player.speed_scale = -1.0
	pulling1_b = true

func _on_hand_grab_let_go(hand: bool) -> void:
	if not use_rail1:
		return
	if not usable1:
		return
	rail_1_animation_player.speed_scale = 0.0
	pulling1_b = false

func _on_hand_grab_2_pulled(hand: bool) -> void:
	if not use_rail1:
		return
	if not usable1:
		return
	if not has_started1:
		rail_1_animation_player.play("StartLeft")
		has_started1 = true
	else:
		if rail_1_animation_player.current_animation_position >= rail_1_animation_player.current_animation_length:
			return
		if not rail_1_animation_player.is_playing():
			rail_1_animation_player.play("StartLeft")
	rail_1_animation_player.speed_scale = 1.0
	pulling1_f = true

func _on_hand_grab_2_let_go(hand: bool) -> void:
	if not use_rail1:
		return
	if not usable1:
		return
	rail_1_animation_player.speed_scale = 0.0
	pulling1_f = false

func _on_hand_grab_pulled2(hand: bool) -> void:
	if not use_rail2:
		return
	if not usable2:
		return
	if not has_started2:
		return
	if rail_2_animation_player.current_animation_position <= 0.0:
		return
	if not rail_2_animation_player.is_playing():
		rail_2_animation_player.play("StartLeft")
		rail_2_animation_player.seek(rail_2_animation_player.current_animation_length, true)
	rail_2_animation_player.speed_scale = -1.0
	pulling2_b = true

func _on_hand_grab_let_go2(hand: bool) -> void:
	if not use_rail2:
		return
	if not usable2:
		return
	rail_2_animation_player.speed_scale = 0.0
	pulling2_b = false

func _on_hand_grab_2_pulled2(hand: bool) -> void:
	if not use_rail2:
		return
	if not usable2:
		return
	if not has_started2:
		rail_2_animation_player.play("StartLeft")
		has_started2 = true
	else:
		if rail_2_animation_player.current_animation_position >= rail_2_animation_player.current_animation_length:
			return
		if not rail_2_animation_player.is_playing():
			rail_2_animation_player.play("StartLeft")
	rail_2_animation_player.speed_scale = 1.0
	pulling2_f = true

func _on_hand_grab_2_let_go2(hand: bool) -> void:
	if not use_rail2:
		return
	if not usable2:
		return
	rail_2_animation_player.speed_scale = 0.0
	pulling2_f = false
