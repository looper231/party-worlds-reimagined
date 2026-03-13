extends Node2D

func delete_locked_text(id: int = 0) -> void:
	var node_name = "LockedText" + str(id)
	if has_node(node_name) and is_instance_valid(node_name):
		get_node(node_name).queue_free()
