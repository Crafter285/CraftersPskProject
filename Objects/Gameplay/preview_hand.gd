@tool
extends Node3D

var cur_anim: String = ""
func play(anim: String):
	$AnimationPlayer.play(anim)
	cur_anim = anim
