extends Node2D

@export_enum("Normal Boss:0", "Alternate Boss:1") var choose_boss_for_next_level: int = 0

func _on_player_detector_body_entered(body: Node2D) -> void:
	var script = body.get_script()
	if script and script.get_global_name() == "Player":
		enforce_route()

func enforce_route() -> void:
	if choose_boss_for_next_level == 1:
		CustomGlobals.w9_alt_boss = true
		SecretsManager.set_secret("9-2 alt path", true, true, true, "world 9-2 alternate route")
	else: CustomGlobals.w9_alt_boss = false
