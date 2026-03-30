extends WorldEnvironment
class_name WorldEnvironmentGraphicsCompatible

@export var low_environment: Environment
@export var medium_environment: Environment
@export var high_environment: Environment
@export var epic_environment: Environment

func _ready() -> void:
	Game.current_environment_node = self
	Game.load_quality_environments()
