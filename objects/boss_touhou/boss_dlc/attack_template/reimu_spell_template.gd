extends BossSpellcardDLC
class_name ReimuSpellcard

func shoot_simple_yinyang(bullet_type: PackedScene, init_position: Vector2 = Vector2.ZERO, b_velocity: Vector2 = Vector2(50.0, 50.0), rotation: float = 0.0) -> void:
	if !check_if_within_playfield(init_position): return
	var bullet_shot = bullet_type.instantiate()
	bullet_shot.rotation = rotation
	bullet_shot.veloc = b_velocity
	bullet_shot.anchor_for_bounce = boss.boss_handler.global_position
	Scenes.current_scene.add_child(bullet_shot)
	boss.bullet_pool.append(bullet_shot)
	bullet_shot.z_index = boss.z_index + 1
	bullet_shot.global_position = init_position
	bullet_shot.reset_physics_interpolation()
	bullet_shot.enable_movement()
	if b_velocity.y < 0:
		bullet_shot.jump(b_velocity.y)

func shoot_yinyang(bullet_type: PackedScene, angle: float = 0.0, speed: float = 300.0) -> void:
	var result_velocity = Vector2(speed * cos(angle), speed * sin(angle))
	shoot_simple_yinyang(bullet_type, boss.global_position, result_velocity, 0.0)

func shoot_simple_homing_bullet(bullet_type: PackedScene, init_position: Vector2 = Vector2.ZERO, b_velocity: Vector2 = Vector2(50.0, 50.0), rotation: float = 0.0, homing_times: int = 1, homing_interval: float = 2.0, homing_speed: float = 50.0) -> void:
	if !check_if_within_playfield(init_position): return
	var bullet_shot = bullet_type.instantiate()
	bullet_shot.rotation = rotation
	bullet_shot.veloc = b_velocity
	bullet_shot.boss_handler = boss.boss_handler
	bullet_shot.homing_times = homing_times
	bullet_shot.homing_speed = homing_speed
	bullet_shot.homing_interval = homing_interval
	Scenes.current_scene.add_child(bullet_shot)
	boss.bullet_pool.append(bullet_shot)
	bullet_shot.z_index = boss.z_index + 1
	bullet_shot.global_position = init_position
	bullet_shot.reset_physics_interpolation()
	bullet_shot.enable_movement()

func shoot_homing_bullet(bullet_type: PackedScene, angle: float = 0.0, speed: float = 50.0, homing_times: int = 1, homing_speed: float = 50.0, homing_interval: float = 2.0) -> void:
	var result_velocity = Vector2(speed * cos(angle), speed * sin(angle))
	shoot_simple_homing_bullet(bullet_type, boss.global_position, result_velocity, angle, homing_times, homing_interval, homing_speed)
