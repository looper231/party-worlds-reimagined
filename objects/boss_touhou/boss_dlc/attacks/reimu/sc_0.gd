extends ReimuSpellcard

const BULLET_RED_AMULET = preload("res://objects/boss_touhou/boss_dlc/attacks/reimu/bullets/bullet_amulet_red.tscn")
const BULLET_GRAY_AMULET = preload("res://objects/boss_touhou/boss_dlc/attacks/reimu/bullets/bullet_amulet_gray.tscn")
const BULLET_YINYANG = preload("res://objects/boss_touhou/boss_dlc/attack_template/bouncy_yinyang.tscn")
const BULLET_YINYANG_BIG = preload("res://objects/boss_touhou/boss_dlc/attacks/reimu/bullets/bouncy_yinyang_big.tscn")

# Amulet settings
const sc0_gray_ring_speed: float = 190.0
const sc0_gray_ring_amount: int = 16
const sc0_red_ring_speed: float = 100.0
const sc0_red_ring_amount: int = 9
# Yin-yang settings
const sc0_yinyang_shoot_zone: float = 233.0

var attacking_phase: bool = false
var is_attacking: bool = false
var yinyang_direction: int = 1
var yinyang_wave_count: int = 0
var use_small_yinyang: bool = false
var total_waves_elapsed: int = 0

func middle_attack() -> void:
	begin_attack = true
	attacking_phase = true
	super()

func _physics_process(delta: float) -> void:
	if _boss_attack_interrupt():
		attacking_phase = false
		return
	# During each attacking phase:
	# 1. Reimu shoots gray and red amulet rings
	# 2. Immediately shoots Yinyangs everywhere
	# 3. End phase and enter wander
	# 4. Wander for 1 second
	# 5. Repeat
	if attacking_phase and !is_attacking:
		is_attacking = true
		if total_waves_elapsed > 3:
			sc0_boss_wander()
			sc0_gradual_small_yinyang(yinyang_direction)
			play_sound(boss.summon_option)
			await _set_timer(1.5)
			if _boss_attack_interrupt(): return
			play_sound(boss.short_charge_up)
			leaf_gather_effect()
			await _set_timer(1.5)
			if _boss_attack_interrupt(): return
			bullet_screen_clear(false)
			sc0_boss_wander()
			var internal_i: int = 0
			while internal_i < 50:
				if _boss_attack_interrupt(): break
				sc0_shoot_gray_amulet_rings(aim_at_player(), clampi(internal_i, 1, 20))
				play_sound(boss.bullet_shoot_1, null, true)
				await _set_timer(0.3)
				if _boss_attack_interrupt(): return
				internal_i += 1
			sc0_boss_wander()
			total_waves_elapsed = 0
			is_attacking = false
			return
		
		var player_angle: float = aim_at_player()
		
		boss_play_attack_anim()
		sc0_shoot_gray_amulet_rings(player_angle, 6)
		play_sound(boss.bullet_shoot_1, null, true)
		await _set_timer(0.1)
		if _boss_attack_interrupt(): return
		sc0_shoot_red_amulet_rings(yinyang_direction, player_angle, 7)
		play_sound(boss.bullet_shoot_1, null, true)
		await _set_timer(0.4)
		if _boss_attack_interrupt(): return
		sc0_gradual_big_yinyang(yinyang_direction)
		play_sound(boss.bullet_shoot_1, null, true)
		play_sound(boss.summon_option)
		yinyang_direction *= -1
		yinyang_wave_count += 1
		total_waves_elapsed += 1
		await _set_timer(0.5)
		if _boss_attack_interrupt(): return
		boss_nice_aura()
		sc0_boss_wander()
		await _set_timer(2.4)
		if _boss_attack_interrupt(): return
		is_attacking = false

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
	attacking_phase = false
	is_attacking = false
	super()

# Angle must be radian when using this function.
func sc0_shoot_amulet_ring(bullet_type: PackedScene, speed: float = 50.0, angle: float = 0.0, amount: int = 5) -> void:
	for i in amount:
		var amulet_angle = angle + ((PI*2) / amount) * i
		var starting_position = boss.global_position
		shoot_bullet_from_position(bullet_type, starting_position, speed, amulet_angle, amulet_angle)

func sc0_shoot_gray_amulet_rings(angle: float = 0.0, ring_amount: int = 4) -> void:
	for i in ring_amount:
		sc0_shoot_amulet_ring(BULLET_GRAY_AMULET, sc0_gray_ring_speed * (1.0 + 0.2 * i), angle, sc0_gray_ring_amount)

func sc0_shoot_red_amulet_rings(direction: int = 1, angle: float = 0.0, ring_amount: int = 3) -> void:
	for i in ring_amount:
		sc0_shoot_amulet_ring(BULLET_RED_AMULET, sc0_red_ring_speed * (1.0 + 0.2 * i), angle + deg_to_rad(3.0) * i * direction, sc0_red_ring_amount)

func sc0_gradual_big_yinyang(direction: int = 1) -> void:
	sc0_shoot_yinyang_gradual(BULLET_YINYANG_BIG, direction, 0.0, 600.0, 5)

func sc0_gradual_small_yinyang(direction: int = 1) -> void:
	sc0_shoot_yinyang_gradual(BULLET_YINYANG, direction, 0.0, 400.0, 27)

func sc0_shoot_yinyang_gradual(bullet_type: PackedScene, direction: int = 1, angle: float = 0.0, speed: float = 500.0, number: int = 5) -> void:
	var shoot_angle_start: float = angle + ((PI/2) + deg_to_rad((360.0 - sc0_yinyang_shoot_zone) / 2.0) * direction)
	var i: int = 0
	while i < number:
		shoot_yinyang(bullet_type, shoot_angle_start + (deg_to_rad(sc0_yinyang_shoot_zone) / number) * i * direction, speed)
		await get_tree().create_timer(0.03, false).timeout
		i += 1

func sc0_boss_wander() -> void:
	var upper_bound = Vector2(300, -90)
	var lower_bound = Vector2(-300, -200)
	move_boss_wander(Wander_Type.RANDOM, boss.boss_handler.global_position, upper_bound, lower_bound, randf_range(80.0, 180.0), 1.7)
