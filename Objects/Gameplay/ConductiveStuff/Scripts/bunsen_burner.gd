extends Node3D

@export var pull_amount: float = 180.0
@export var glass: Array[Node]

var pull_speed: float = 400.0
var pulling: bool = false
var pulled_amount: float = 0.0

signal pulled_full
signal fire_emited
signal glass_broken

func _ready() -> void:
	$ConductiveMachanic.show()

func _process(delta: float) -> void:
	if pulling:
		pulled_amount += pull_speed * delta
		$Valve.rotation_degrees.z += pull_speed * delta
		if pulled_amount > pull_amount:
			pulling = false
			$Turning.stop()
			$Stopped.play()
			$Valve/HandGrab.enabled = false
			pulled()

func _on_hand_grab_let_go(hand: bool) -> void:
	pulling = false
	$Turning.stop()

func _on_hand_grab_pulled(hand: bool) -> void:
	pulling = true
	$Turning.play()

func pulled():
	$GasGPUParticles3D2.emitting = true
	$ConductiveMachanic.enabled = true
	pulled_full.emit()

func fire():
	fire_emited.emit()
	$GasGPUParticles3D2.emitting = false
	$FireGPUParticles3D.emitting = true
	await get_tree().create_timer(3.0).timeout
	$SM_ExplodingBeaker_B_mo.hide()
	$GlassBreaking.play()
	glass_broken.emit()
	for GlassPressure in glass:
		GlassPressure.crack_glass()
	await get_tree().create_timer(0.5).timeout
	$FireGPUParticles3D.emitting = false

func _on_conductive_machanic_fire_released() -> void:
	fire()
