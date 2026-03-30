extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer2

var charged_color: Color = "00ffff"
var empty_color: Color = "000000"

var can_use_scanner: bool = true

func _ready() -> void:
	for i in Game.omni_charges:
		var charge_path: String = str("Skeleton3DE/charge", 4-i)
		var charge: StandardMaterial3D = get_node(charge_path).get_surface_override_material(0)
		charge.albedo_color = charged_color
func used():
	if Game.omni_charges < 1: return
	Game.omni_charges -= 1
	animation_player.play("used")
	#Unlight Charge:
	var charge_path: String = str("Skeleton3DE/charge", 4-Game.omni_charges)
	var charge: StandardMaterial3D = get_node(charge_path).get_surface_override_material(0)
	charge.albedo_color = empty_color
