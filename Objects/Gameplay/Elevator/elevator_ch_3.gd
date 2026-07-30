extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var start = false

func Start() -> void:
	animation_player.play("Open")
	start = true


var ono = false
func _on_area_3d_body_entered(body: Node3D) -> void:
	if not body.is_in_group("Player"):
		return
	if ono == false:
		if start == true:
			ono = true
			animation_player.play("Close")
			await get_tree().create_timer(2).timeout
			animation_player.play("Up")
			await get_tree().create_timer(2).timeout
			animation_player.play("OpenUp")
