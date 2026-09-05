extends Node2D

@export var delete_node_after_increments: int = 4
var delete_node_var: int = 0

func disable_rematch_bool() -> void:
	CustomGlobals.is_boss_rematch = false
	print("[Save Game Room] Disabled Boss Rematch mode.")

func enable_rematch_bool() -> void:
	CustomGlobals.is_boss_rematch = true
	print("[Save Game Room] Enabled Boss Rematch mode.")

func increment_deleted() -> void:
	delete_node_var += 1
	if delete_node_var >= delete_node_after_increments:
		hide()
		process_mode = Node.PROCESS_MODE_DISABLED
