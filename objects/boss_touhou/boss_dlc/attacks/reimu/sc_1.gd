extends ReimuSpellcard

const BULLET_HOMING_GRAY = preload("res://objects/boss_touhou/boss_dlc/attacks/reimu/bullets/bullet_homing_amulet_gray.tscn")
const BULLET_AMULET_RED = preload("res://objects/boss_touhou/boss_dlc/attacks/reimu/bullets/bullet_amulet_red.tscn")
const BULLET_BIGCIRCLE_RED = preload("res://objects/boss_touhou/boss_dlc/attacks/reimu/bullets/bullet_bigcircle_red.tscn")

# Homing Amulet settings
const sc1_homing_speed: float = 170.0
const sc1_homing_times: int = 1
const sc1_homing_interval: float = 1.0
const sc1_homing_ring_count: int = 4
const sc1_homing_ring_amulets: int = 40
# Red Amulet settings
const sc1_red_spread_speed: float = 180.0
const sc1_red_spread_waves: int = 8
const sc1_red_spread_amount: int = 9
const sc1_red_focus_noise_speed: float = 300.0
const sc1_red_focus_noise_amount: int = 17
const sc1_red_focus_speed_min: float = 200.0
const sc1_red_focus_speed_max: float = 700.0
const sc1_red_focus_cone: float = deg_to_rad(8)
const sc1_red_focus_waves: int = 16
const sc1_red_focus_amount: int = 3

var sc1_attack_wave_start: bool = false
var increase_difficulty: bool = false

func middle_attack() -> void:
	boss_to_default_start_pos()
	await _set_timer(0.5)
	leaf_gather_effect()
	play_sound(boss.short_charge_up)
	await _set_timer(1.2)
	begin_attack = true
	sc1_attack_wave_start = true
	super()

func _physics_process(delta: float) -> void:
	if _boss_attack_interrupt():
		sc1_attack_wave_start = false
		return
	if sc1_attack_wave_start:
		sc1_attack_wave_start = false
		
		# Spread danmaku.
		var spread_waves: int = 8
		while spread_waves > 0:
			sc1_shoot_red_spread(sc1_red_spread_speed, aim_at_player(), clampi(sc1_red_spread_waves - spread_waves, 2, sc1_red_spread_waves))
			play_sound(boss.bullet_shoot_1, null, true)
			spread_waves -= 1
			await _set_timer(0.4)
			if _boss_attack_interrupt(): return
		# Homing gray amulets.
		var homing_waves: int = 0
		while homing_waves < 4:
			sc1_boss_wander(0.5)
			sc1_shoot_homing_ring(sc1_homing_speed, aim_at_player(), sc1_homing_ring_amulets, sc1_homing_ring_count)
			if increase_difficulty:
				sc1_shoot_amulet_ring(BULLET_AMULET_RED, sc1_red_focus_noise_speed, aim_at_player(), sc1_red_focus_noise_amount)
			play_sound(boss.bullet_shoot_1, null, true)
			homing_waves += 1
			await _set_timer(2.0)
			if _boss_attack_interrupt(): return
		# Downtime.
		leaf_gather_effect()
		play_sound(boss.short_charge_up)
		await _set_timer(1.2)
		if _boss_attack_interrupt(): return
		# Focus shot amulets.
		for i in 3:
			sc1_shoot_red_focus(aim_at_player())
			sc1_shoot_homing_ring(sc1_homing_speed * 1.2, aim_at_player(), sc1_homing_ring_amulets, sc1_homing_ring_count / 2)
			play_sound(boss.bullet_shoot_1, null, true)
			await _set_timer(1.0)
			if _boss_attack_interrupt(): return
			sc1_shoot_amulet_ring(BULLET_AMULET_RED, sc1_red_focus_noise_speed, aim_at_player(), sc1_red_focus_noise_amount)
			sc1_shoot_homing_ring(sc1_homing_speed * 1.2, aim_at_player(), sc1_homing_ring_amulets, sc1_homing_ring_count / 2)
			play_sound(boss.bullet_shoot_1, null, true)
			sc1_boss_chase()
			await _set_timer(1.0)
			if _boss_attack_interrupt(): return
		increase_difficulty = true
		sc1_attack_wave_start = true

func end_attack() -> void:
	super()
	bullet_screen_clear()
	play_sound(boss.bullet_shoot_1)
	player_gain_score(spellcard_score_bonus)
	goto_next_spell()

func force_end_attack() -> void:
	end_attack_global()
	super()

func end_attack_global() -> void:
	begin_attack = false
	sc1_attack_wave_start = false
	increase_difficulty = false
	super()

# Angle must be radian when using this function.
func sc1_shoot_amulet_ring(bullet_type: PackedScene, speed: float = 50.0, angle: float = 0.0, amount: int = 5) -> void:
	for i in amount:
		var amulet_angle = angle + ((PI*2) / amount) * i
		var starting_position = boss.global_position
		shoot_bullet_from_position(bullet_type, starting_position, speed, amulet_angle, amulet_angle)

func sc1_shoot_homing_ring(speed: float = 50.0, angle: float = 0.0, amount_per_ring: int = 10, ring_count: int = 3) -> void:
	for i in ring_count:
		for k in amount_per_ring:
			var amulet_angle = angle + ((PI*2) / amount_per_ring) * k
			var starting_position = boss.global_position
			shoot_homing_bullet(BULLET_HOMING_GRAY, amulet_angle, speed * (1.0 + clampf(0.3 * i, 0.0, 999.0)), sc1_homing_times, sc1_homing_speed, sc1_homing_interval)

func sc1_shoot_red_spread(speed: float = 50.0, angle: float = 0.0, wave_count: int = 3) -> void:
	for i in wave_count:
		sc1_shoot_amulet_ring(BULLET_AMULET_RED, speed * (1.0 + (0.2 * i)), angle + (PI * (i % 2)), sc1_red_spread_amount)

func sc1_shoot_red_focus(angle: float = 0.0) -> void:
	const sc1_focus_speed_diff: float = (sc1_red_focus_speed_max - sc1_red_focus_speed_min) / sc1_red_focus_waves
	var starting_position = boss.global_position
	for i in sc1_red_focus_waves:
		var focus_speed_wave: float = sc1_red_focus_speed_min + (sc1_focus_speed_diff * i)
		play_sound(boss.bullet_shoot_1, null, true)
		for k in sc1_red_focus_amount:
			var focus_angle: float = angle - (sc1_red_focus_cone / 2) + ((sc1_red_focus_cone / (sc1_red_focus_amount - 1)) * k)
			shoot_bullet_from_position(BULLET_AMULET_RED, starting_position, focus_speed_wave, focus_angle, focus_angle)
		await _set_timer(0.06)

func sc1_boss_wander(duration: float = 1.0) -> void:
	var upper_bound = Vector2(300, -90)
	var lower_bound = Vector2(-300, -200)
	move_boss_wander(Wander_Type.RANDOM, boss.boss_handler.global_position, upper_bound, lower_bound, randf_range(80.0, 230.0), duration)

func sc1_boss_chase() -> void:
	var upper_bound = Vector2(300, -90)
	var lower_bound = Vector2(-300, -200)
	move_boss_wander(Wander_Type.MOVE_TOWARDS_PLAYER, boss.boss_handler.global_position, upper_bound, lower_bound, randf_range(80.0, 230.0), 0.5)
