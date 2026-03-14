extends "res://addons/secrets_manager/secret_unlocker.gd"

const world_name = "10"

func _end_world_functions() -> void:
	if Thunder.autosplitter.can_split_on("world_complete"):
		Thunder.autosplitter.split("Last World Completed")
	if !ProfileManager.current_profile.has_completed_world(world_name):
		ProfileManager.current_profile.complete_world(world_name)
		ProfileManager.save_current_profile()
