@tool
extends Resource
class_name LinkedPuzzle

@export var puzzle: NodePath:
	set(value):
		puzzle = value
		if Engine.is_editor_hint(): notify_property_list_changed()
var enable_signal: String:
	set(value):
		enable_signal = value
var disable_signal: String:
	set(value):
		disable_signal = value
var stored_signalE: String
var stored_signalD: String

var linker_node: Node

func _get_property_list() -> Array[Dictionary]:
	var props: Array[Dictionary] = []

	if linker_node and linker_node.has_node(puzzle):
		var node = linker_node.get_node(puzzle)
		var script = node.get_script()
		if script:
			var signal_list = script.get_script_signal_list()
			var signal_names: Array[String] = []
			for s in signal_list:
				signal_names.append(s.name)
			signal_names.append("None")

			props.append({
				"name": "enable_signal",
				"type": TYPE_STRING,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": ",".join(signal_names),
				"usage": PROPERTY_USAGE_DEFAULT
			})
			
			props.append({
				"name": "disable_signal",
				"type": TYPE_STRING,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": ",".join(signal_names),
				"usage": PROPERTY_USAGE_DEFAULT
			})
	
	return props
