extends StaticBody3D

@export var powered_on: bool = false
@export var puzzle: Node = null
@export var on_signal: String = ""
@export var off_signal: String = ""

@onready var power_label: Label = $SM_ConsolsMonitor_A/SubViewportContainer/SubViewport/Control/PowerLabel

func _ready() -> void:
	if on_signal != "": puzzle.connect(on_signal, Callable(power_on))
	if off_signal != "": puzzle.connect(off_signal, Callable(power_off))
	if powered_on: power_on()
	else: power_off()

func power_on():
	power_label.text = "POWER ON"
	power_label.modulate = Color.GREEN
func power_off():
	power_label.text = "POWER OFF"
	power_label.modulate = Color.RED
