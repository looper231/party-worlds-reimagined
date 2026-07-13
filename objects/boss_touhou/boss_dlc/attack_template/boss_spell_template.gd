extends BossSpellcard
class_name BossSpellcardDLC

func start_attack() -> void:
	if is_spell_card: boss.spawn_spell_ring_effect()
	if boss.finished_init:
		middle_attack()
		super()
		return
	await easy_setup_boss_enter()
	middle_attack()
	super()

# End pattern (normally)
func end_attack() -> void:
	restore_time()
	if boss.boss_sprite.animation == &"attack":
		reset_boss_anim()
	if boss.current_spell_index < boss.max_number_of_spellcards + 1:
		player_gain_pity()
	end_attack_global()
	end.emit()

# Forcibly end the pattern due to player death, etc.
func force_end_attack() -> void:
	boss.keep_sc_bg = false
	end_attack_global()
	forced_end.emit()

# Called by both methods of ending an attack
func end_attack_global() -> void:
	boss.delete_spell_ring_effect()
	super()

func easy_setup_boss_enter() -> void:
	spellcard_time += 3.0
	var old_pos = boss.starting_position
	if boss.boss_handler:
		old_pos = boss.boss_handler.global_position
	var new_x = 0.0
	var new_y = -100.0
	if boss.hatate_mode and player:
		new_y = -120.0
		if player.global_position.x > boss.boss_handler.global_position.x: new_x = -160
		if player.global_position.x < boss.boss_handler.global_position.x: new_x = 160
	move_boss(old_pos + Vector2(new_x, new_y), 1.0)
	await _set_timer(0.2)
	boss.finished_init = true
	boss.magic_circle_effect.appear_animation()
	play_sound(boss.long_charge_up)
	await _set_timer(0.8)
	play_sound(boss.short_charge_up)
	leaf_gather_effect()
	await _set_timer(1.3)

func boss_to_default_start_pos() -> void:
	move_boss(boss.boss_handler.global_position + Vector2(0.0, -160.0))

func reset_boss_anim_from_attack() -> void:
	if !boss: return
	if boss.boss_sprite.animation == &"attack" and boss.attack_anim_ended:
		reset_boss_anim()

func goto_next_spell() -> void:
	if !boss: return
	if boss.force_end_player_death: return
	await _set_timer(0.1)
	boss.start_next_spell_card(boss.current_spell_index)
