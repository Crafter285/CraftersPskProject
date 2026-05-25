@tool
extends Node3D

enum line_hight { high, middle, low }
enum line_difficulty { impossible, hard, middium, easy }

@export var hight: line_hight = line_hight.middle:
	set(value):
		hight = value
		_update_height()

@export var difficulty: line_difficulty = line_difficulty.easy:
	set(value):
		difficulty = value
		_update_difficulty()

var puzzle_completed: bool = false
var current_difficulty: String = ""
var current_hight: String = ""
var pressure_power: float = 0.0
var plunger_minimum_hight: float = 1.1
var plunger_maximum_hight: float = 3.0
var plunger_drain_speed: float = 0.1
var in_area: bool = false
var _plunger_tween: Tween = null
var _current_target_y: float = 0.0

signal completed

# ── Area refs ─────────────────────────────────────────────────────────────────

@onready var area_high_easy: Area3D = $LinePos/High/Easy/HighEasy
@onready var area_high_middium: Area3D = $LinePos/High/Midium/HighMiddium
@onready var area_high_hard: Area3D = $LinePos/High/Hard/HighHard
@onready var area_high_impossible: Area3D = $LinePos/High/Imposible/HighImposible
@onready var area_middle_easy: Area3D = $LinePos/Middle/Easy/MiddleEasy
@onready var area_middle_middium: Area3D = $LinePos/Middle/Midium/MiddleMidium
@onready var area_middle_hard: Area3D = $LinePos/Middle/Hard/MiddleHard
@onready var area_middle_impossible: Area3D = $LinePos/Middle/Imposible/MiddleImpossible
@onready var area_low_easy: Area3D = $LinePos/Low/Easy/LowEasy
@onready var area_low_middium: Area3D = $LinePos/Low/Midium/LowMidium
@onready var area_low_hard: Area3D = $LinePos/Low/Hard/LowHard
@onready var area_low_impossible: Area3D = $LinePos/Low/Imposible/LowImpossible


func _ready() -> void:
	_current_target_y = plunger_minimum_hight
	if Engine.is_editor_hint():
		$PressureMachanic.hide()
	else:
		$PressureMachanic.show()
	_update_height()
	_update_difficulty()
	_setup_areas()


func _all_areas() -> Array:
	return [
		area_high_easy, area_high_middium, area_high_hard, area_high_impossible,
		area_middle_easy, area_middle_middium, area_middle_hard, area_middle_impossible,
		area_low_easy, area_low_middium, area_low_hard, area_low_impossible,
	]


func _get_current_area() -> Area3D:
	match hight:
		line_hight.high:
			match difficulty:
				line_difficulty.easy:       return area_high_easy
				line_difficulty.middium:    return area_high_middium
				line_difficulty.hard:       return area_high_hard
				line_difficulty.impossible: return area_high_impossible
		line_hight.middle:
			match difficulty:
				line_difficulty.easy:       return area_middle_easy
				line_difficulty.middium:    return area_middle_middium
				line_difficulty.hard:       return area_middle_hard
				line_difficulty.impossible: return area_middle_impossible
		line_hight.low:
			match difficulty:
				line_difficulty.easy:       return area_low_easy
				line_difficulty.middium:    return area_low_middium
				line_difficulty.hard:       return area_low_hard
				line_difficulty.impossible: return area_low_impossible
	return area_middle_easy


func _setup_areas() -> void:
	var current: Area3D = _get_current_area()
	for area in _all_areas():
		if area != current:
			area.get_parent().queue_free()


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	var old_power: float = pressure_power
	pressure_power = max(0.0, pressure_power - plunger_drain_speed * delta)
	if abs(pressure_power - old_power) > 0.001:
		_update_plunger()


func _on_hand_grab_pulled(hand: bool) -> void:
	$LeverPullSFX.play()
	if in_area:
		$LeverAnimationPlayer.play("pull_complete")
		$PressureMachanic.queue_free()
		$HandGrab.queue_free()
		completed.emit()
	else:
		pressure_power = 0.0
		_update_plunger()
		$LeverAnimationPlayer.play("pull")


func _on_pressure_machanic_power_any(amount: float) -> void:
	pressure_power = clamp(pressure_power + amount, 0.0, 1.0)
	push()


func push() -> void:
	$ButtonAnimationPlayer.play("Push")
	$PressurePushSFX.play()
	_update_plunger()


func _update_plunger() -> void:
	var plunger: Node3D = $Meshes/TankPlunger
	_current_target_y = lerp(plunger_minimum_hight, plunger_maximum_hight, pressure_power)
	if _plunger_tween:
		_plunger_tween.kill()
	_plunger_tween = create_tween()
	_plunger_tween.tween_property(plunger, "position:y", _current_target_y, 0.3).set_trans(Tween.TRANS_SINE)


# ── Area3D signal helpers ─────────────────────────────────────────────────────

func _on_area_plunger_entered(body: Node3D) -> void:
	if not body.is_in_group("Plunger"):
		return
	in_area = true


func _on_area_plunger_exited(body: Node3D) -> void:
	if not body.is_in_group("Plunger"):
		return
	in_area = false


# ── High ──────────────────────────────────────────────────────────────────────

func _on_high_easy_body_entered(body: Node3D) -> void:
	_on_area_plunger_entered(body)

func _on_high_easy_body_exited(body: Node3D) -> void:
	_on_area_plunger_exited(body)

func _on_high_middium_body_entered(body: Node3D) -> void:
	_on_area_plunger_entered(body)

func _on_high_middium_body_exited(body: Node3D) -> void:
	_on_area_plunger_exited(body)

func _on_high_hard_body_entered(body: Node3D) -> void:
	_on_area_plunger_entered(body)

func _on_high_hard_body_exited(body: Node3D) -> void:
	_on_area_plunger_exited(body)

func _on_high_imposible_body_entered(body: Node3D) -> void:
	_on_area_plunger_entered(body)

func _on_high_imposible_body_exited(body: Node3D) -> void:
	_on_area_plunger_exited(body)


# ── Middle ────────────────────────────────────────────────────────────────────

func _on_middle_easy_body_entered(body: Node3D) -> void:
	_on_area_plunger_entered(body)

func _on_middle_easy_body_exited(body: Node3D) -> void:
	_on_area_plunger_exited(body)

func _on_middle_midium_body_entered(body: Node3D) -> void:
	_on_area_plunger_entered(body)

func _on_middle_midium_body_exited(body: Node3D) -> void:
	_on_area_plunger_exited(body)

func _on_middle_hard_body_entered(body: Node3D) -> void:
	_on_area_plunger_entered(body)

func _on_middle_hard_body_exited(body: Node3D) -> void:
	_on_area_plunger_exited(body)

func _on_middle_impossible_body_entered(body: Node3D) -> void:
	_on_area_plunger_entered(body)

func _on_middle_impossible_body_exited(body: Node3D) -> void:
	_on_area_plunger_exited(body)


# ── Low ───────────────────────────────────────────────────────────────────────

func _on_low_easy_body_entered(body: Node3D) -> void:
	_on_area_plunger_entered(body)

func _on_low_easy_body_exited(body: Node3D) -> void:
	_on_area_plunger_exited(body)

func _on_low_midium_body_entered(body: Node3D) -> void:
	_on_area_plunger_entered(body)

func _on_low_midium_body_exited(body: Node3D) -> void:
	_on_area_plunger_exited(body)

func _on_low_hard_body_entered(body: Node3D) -> void:
	_on_area_plunger_entered(body)

func _on_low_hard_body_exited(body: Node3D) -> void:
	_on_area_plunger_exited(body)

func _on_low_impossible_body_entered(body: Node3D) -> void:
	_on_area_plunger_entered(body)

func _on_low_impossible_body_exited(body: Node3D) -> void:
	_on_area_plunger_exited(body)


# ── Height / difficulty visuals ───────────────────────────────────────────────

func _update_height() -> void:
	if not is_node_ready():
		return
	$LinePos/High.hide()
	$LinePos/Middle.hide()
	$LinePos/Low.hide()
	match hight:
		line_hight.high:   $LinePos/High.show();   current_hight = "High"
		line_hight.middle: $LinePos/Middle.show();  current_hight = "Middle"
		line_hight.low:    $LinePos/Low.show();     current_hight = "Low"


func _update_difficulty() -> void:
	if not is_node_ready():
		return
	var heights: Array = ["High", "Middle", "Low"]
	var difficulties: Array = ["Easy", "Midium", "Hard", "Imposible"]
	for h in heights:
		for d in difficulties:
			$LinePos.get_node(h + "/" + d).hide()
	var diff_name: String
	match difficulty:
		line_difficulty.easy:       diff_name = "Easy";      current_difficulty = "Easy"
		line_difficulty.middium:    diff_name = "Midium";    current_difficulty = "Midium"
		line_difficulty.hard:       diff_name = "Hard";      current_difficulty = "Hard"
		line_difficulty.impossible: diff_name = "Imposible"; current_difficulty = "Imposible"
	for h in heights:
		$LinePos.get_node(h + "/" + diff_name).show()
