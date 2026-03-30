extends Node3D

var retract_paused: bool = false

func clear_wire():
	for i in get_child_count():
		get_child(i).queue_free()

func has_start():
	var has_start_bool: bool = false
	for i in get_child_count():
		if get_child(i).first:
			has_start_bool = true
	return has_start_bool
func has_end():
	var has_end_bool: bool = false
	for i in get_child_count():
		if get_child(i).last:
			has_end_bool = true
	return has_end_bool

func get_last_point():
	return get_child(get_child_count()-1)
func update_last_to_last():
	if get_child(get_child_count()-1): get_child(get_child_count()-1).last = true

func next_retract_point():
	if get_child(get_child_count()-1): get_child(get_child_count()-1).queue_free()
	if get_child(get_child_count()-2): get_child(get_child_count()-2).last = true
