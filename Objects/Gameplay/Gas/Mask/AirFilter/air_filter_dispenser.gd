extends StaticBody3D

@onready var dispensed_location: Marker3D = $DispensedLocation
@onready var animation_player: AnimationPlayer = $AnimationPlayer

const AIR_FILTER = preload("res://Objects/Gameplay/Gas/Mask/AirFilter/air_filter.tscn")

func dispense():
	if animation_player.is_playing(): return
	var new_filter: RigidBody3D = AIR_FILTER.instantiate()
	add_child(new_filter)
	new_filter.position = dispensed_location.position
	animation_player.play("Push")

func _on_button_pressed() -> void:
	dispense()
