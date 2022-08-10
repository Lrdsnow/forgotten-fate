extends Node3D

func _ready():
	if not Global.mod_env_override:
		Global.env = $WorldEnvironment.environment

