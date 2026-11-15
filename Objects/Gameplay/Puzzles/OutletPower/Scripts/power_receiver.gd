extends StaticBody3D

@export var ch5_model: bool = false
@export var power_poles: Array[NodePath]

@onready var light = $OmniLight3D
@onready var grabbed = $Grabbed

var completed: bool = false
var grabbedhand: bool = false

signal powered

func _ready():
	
	if ch5_model == true:
		$PowerSource/PowerSource_MI_PowerSource_0.hide()
		$PowerSource/SM_Power_Receiver_A_mo_003.show()
	elif ch5_model == false:
		$PowerSource/PowerSource_MI_PowerSource_0.show()
		$PowerSource/SM_Power_Receiver_A_mo_003.hide()
	
	light.visible = false

func grabbed_success():
	light.visible = true
	powered.emit()
	grabbed.play()
	if grabbedhand:
		Grabpack.left_retract()
	else:
		Grabpack.right_retract()
	completed = true
func check_poles():
	for i in power_poles.size():
		var path = power_poles[i]
		if not get_node(path).is_powered:
			return false
	return true

func _on_hand_grab_grabbed(hand):
	grabbedhand = hand
	if check_poles() and Grabpack.grabpack.wire_powered and not completed:
		grabbed_success()
