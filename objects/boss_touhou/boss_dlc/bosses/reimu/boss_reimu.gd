extends TouhouBossGeneric

# Positive is left, negative is right
func _animation_process(delta: float) -> void:
	if !boss_sprite: return
	else: boss_sprite.flip_h = false

func start_move_anim() -> void:
	if direction < 0:
		boss_sprite.play(&"move_left")
	else:
		boss_sprite.play(&"move_right")
	is_moving = true

func end_move_anim() -> void:
	if direction < 0:
		boss_sprite.play(&"stop_left")
	else:
		boss_sprite.play(&"stop_right")
	is_moving = false

func _on_boss_sprite_animation_finished() -> void:
	if boss_sprite.animation == &"stop_left" or boss_sprite.animation == &"stop_right":
		adapt_direction(0.0)
		boss_sprite.play(&"default")
		is_moving = false
	if boss_sprite.animation == &"attack":
		attack_anim_ended = true

func adapt_direction(vector_x: float, force_direction_to_take: bool = false, direction_to_take: int = 1) -> void:
	if force_direction_to_take:
		direction = direction_to_take
		return
	if vector_x < 0: direction = 1
	else: direction = -1


func _on_boss_sprite_animation_changed() -> void:
	if !is_instance_valid(boss_sprite): return
	
	match boss_sprite.animation:
		&"attack": boss_sprite.offset = Vector2(0.0, -20.0)
		&"move_left": boss_sprite.offset = Vector2(20.0, 0.0)
		&"stop_left": boss_sprite.offset = Vector2(20.0, 0.0)
		_: boss_sprite.offset = Vector2.ZERO
