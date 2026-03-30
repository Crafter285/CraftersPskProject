extends Node3D

@onready var arm_attach: BoneAttachment3D = $"../LayerWalk/CanonAttachLeft/ArmAttach"
@onready var glowby = $GlowbyGrabpack

func _process(delta: float) -> void:
	glowby.global_transform = arm_attach.global_transform
	glowby.scale = Vector3(1, 1, 1)

	var player = get_tree().get_first_node_in_group("Player")
	if player:
		if player.start_with_glowby == true:
			$GlowbyGrabpack.show()
		elif player.start_with_glowby == false:
			$GlowbyGrabpack.hide()
