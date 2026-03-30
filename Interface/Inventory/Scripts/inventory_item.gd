extends Button

@onready var inventory = $"../../../../.."

var has_desc: bool = false
var description: String = "none"
var item_texture: Texture2D
var item_idx: int = -1

func _ready():
	connect("pressed", Callable(inventory, "item_clicked").bind(self))
