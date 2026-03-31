extends Node3D

@export var conductive_panel: Node3D
##if true then it loses power after 15 seconds
@export var Loses_Power: bool = true

@onready var omni_light_3d = $OmniLight3D
@onready var charged: AudioStreamPlayer = $Electric_Release

var powered: bool = false
var remaining_power: float = 0.0
var _reset_timer: Timer
var ONOLoses_Power: bool = false

signal gained_power
signal lost_power

func _ready() -> void:
	_reset_timer = Timer.new()
	_reset_timer.wait_time = 15.0
	_reset_timer.one_shot = true
	add_child(_reset_timer)
	_reset_timer.timeout.connect(_on_reset_timer_timeout)

func _on_hand_grab_grabbed(hand: bool) -> void:
	if hand and Grabpack.right_hand.current_hand_node.name == "ConductiveHand":
		if conductive_panel.is_electricity2 == true:
			if ONOLoses_Power == false:
				if Loses_Power == false:
					ONOLoses_Power = true
					$Electric_Panel_LOOP.play()
				else:
					_reset_timer.start()
					$Electric_Panel_LOOP.play()
				conductive_panel._reset_uv()
				$HandGrab.enabled = false
				$OmniLight3D.show()
				gained_power.emit()
				charged.play()

func _on_reset_timer_timeout() -> void:
	$HandGrab.enabled = true
	$Electric_Panel_LOOP.stop()
	$AudioStop.play()
	$OmniLight3D.hide()
	lost_power.emit()

func _on_electric_panel_loop_finished() -> void:
	if ONOLoses_Power == true:
		$Electric_Panel_LOOP.play()
