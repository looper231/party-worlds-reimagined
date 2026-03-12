extends Node

func _minecraft_level_complete() -> void:
	SecretsManager.set_secret("minecraft extra", true, true, true, "minecraft level completed")
