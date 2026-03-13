extends "res://engine/objects/warps/door/door_in.gd"

func _physics_process(delta: float) -> void:
	super(delta)
	
	if !monitoring: return
	
	if Data.values.time <= 260 and monitoring:
		monitoring = false
		var disappear_tween = get_tree().create_tween()
		disappear_tween.tween_property(self, "modulate:a", 0.0, 0.5)
		disappear_tween.tween_callback(func() -> void: queue_free())

func _on_animation_finished() -> void:
	super()
	if sprite.animation == &"close":
		Thunder._current_player.sprite.hide()

func _lock_player_status() -> void:
	Thunder._current_player.completed = true
