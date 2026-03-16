extends "res://engine/objects/warps/door/door_in.gd"

@export var timer_disappear_threshold: int = 265

func _ready() -> void:
	super()
	if Data.values.checkpoint != -1:
		queue_free()

func _physics_process(delta: float) -> void:
	super(delta)
	
	if !monitoring: return
	
	if Data.values.time <= timer_disappear_threshold and monitoring:
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
