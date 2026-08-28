extends Node3D

@export var max_charge: float = 2.70
@export var stop_particles_on_full: bool = false
@export var enabled: bool = true

var charge: float = 0.0
var is_charging: bool = false
var fully_charged: bool = false
var is_enabled: bool = true

signal power_25(amount: float)
signal power_50(amount: float)
signal power_75(amount: float)
signal power_100(amount: float)
signal power_any(amount: float)

@onready var pressure_ui = get_tree().get_root().find_child("pressure", true, false)
@onready var hand_grab: Area3D = $HandGrab

var _cached_particles: Array = []
var _cached_hand_node = null

func _ready() -> void:
	is_enabled = enabled
	hand_grab.enabled = false
	var audio = AudioStreamPlayer3D.new()
	audio.name = "ChargeSound"
	var stream = load("res://Objects/Gameplay/PressureStuff/SFX/SW_SFX_Grabpack_PressureHand_Build.wav")
	audio.stream = stream
	audio.autoplay = false
	add_child(audio)

func _get_particles() -> Array:
	var hand = Grabpack.right_hand.current_hand_node
	if hand != _cached_hand_node:
		_cached_hand_node = hand
		if hand and hand.name == "PressureHand":
			_cached_particles = [hand.get_node("GPUParticles3D"), hand.get_node("GPUParticles3D2")]
		else:
			_cached_particles = []
	return _cached_particles

func _is_pressure_hand() -> bool:
	var hand = Grabpack.right_hand.current_hand_node
	return hand != null and hand.name == "PressureHand"

func _process(delta: float) -> void:
	var should_enable = is_enabled and _is_pressure_hand()
	if hand_grab.enabled != should_enable:
		hand_grab.enabled = should_enable

	if is_charging:
		if not _is_pressure_hand():
			is_charging = false
			_stop_charge_effects()
			return

		charge += delta
		charge = clamp(charge, 0.0, max_charge)
		$Label3D.text = "%.2f" % charge
		pressure_ui.update_charge(charge / max_charge)

		if charge >= max_charge and not fully_charged:
			fully_charged = true
			$ChargeSound.stop()
			if stop_particles_on_full:
				for p in _get_particles():
					p.emitting = false
		
		if not fully_charged:
			if not $ChargeSound.playing:
				$ChargeSound.play()
			for p in _get_particles():
				p.emitting = true
	else:
		_stop_charge_effects()

func _stop_charge_effects() -> void:
	if $ChargeSound.playing:
		$ChargeSound.stop()
	for p in _get_particles():
		p.emitting = false

func _on_hand_grab_pulled(hand: bool) -> void:
	if is_enabled and hand and _is_pressure_hand():
		is_charging = true
		fully_charged = false

func _on_hand_grab_let_go(hand: bool) -> void:
	if is_charging:
		is_charging = false
		fire()

func fire():
	var power = charge / max_charge
	call_deferred("_emit_power_signals", power)
	charge = 0.0
	fully_charged = false
	$Label3D.text = "0.00"
	$Label3D.visible = false
	pressure_ui.reset_charge()
	for p in _get_particles():
		p.emitting = false
	_cached_hand_node = null
	_cached_particles = []

func _emit_power_signals(power: float) -> void:
	power_any.emit(power)
	if power >= 1.0:
		power_100.emit(power)
	elif power >= 0.75:
		power_75.emit(power)
	elif power >= 0.5:
		power_50.emit(power)
	elif power >= 0.25:
		power_25.emit(power)

func enable():
	is_enabled = true

func disable():
	is_enabled = false
