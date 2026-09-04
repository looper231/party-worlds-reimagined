extends Node2D

func disable_rematch_bool() -> void:
	CustomGlobals.is_boss_rematch = false
	print("[Save Game Room] Disabled Boss Rematch mode.")

func enable_rematch_bool() -> void:
	CustomGlobals.is_boss_rematch = true
	print("[Save Game Room] Enabled Boss Rematch mode.")
