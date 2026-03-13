extends Node2D

func _ready() -> void:
	CustomGlobals.load_unlockables_status()
	if !SecretsManager.has_secret("main clear") and !CustomGlobals.unlock_fancy_credits: queue_free()
