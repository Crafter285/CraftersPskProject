extends Node2D

@export var root_path : NodePath
@export var button_offset: float = -19.0

func _ready() -> void:
	hide()
	assert(root_path != null, "Empty root path for UI buttons!")

	install_buttons(get_node(root_path))

func install_buttons(node: Node) -> void:
	for i in node.get_children():
		if i is Button:
			i.mouse_entered.connect( func(): mouse_on(i))
			i.mouse_exited.connect( func(): mouse_off())
		
		#repeat
		install_buttons(i)

func mouse_on(btn: Button):
	global_position.x = btn.global_position.x+button_offset
	global_position.y = btn.global_position.y
	show()
func mouse_off():
	hide()
