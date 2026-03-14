extends Command

# Only usable when W9 Boss exists
static func register() -> Command:
	return new().set_name("end_battle").set_description("[W9 Boss/Final Boss Only] Forcibly ends the battle in the player's favor")

func execute(args:Array) -> Command.ExecuteResult:
	var is_final_boss: bool = false
	var boss
	var second_boss
	var handler
	var children_list = Scenes.current_scene.get_children(false)
	for i in children_list.size():
		if "bossw9" in children_list[i].name.to_lower():
			boss = children_list[i]
		if "finalbosshandler" in children_list[i].name.to_lower():
			is_final_boss = true
			handler = children_list[i]
		if is_final_boss:
			if "bossremilia" in children_list[i].name.to_lower():
				boss = children_list[i]
			if "kevinmarisa" in children_list[i].name.to_lower():
				second_boss = children_list[i]
	if !is_final_boss:
		if !is_instance_valid(boss): return Command.ExecuteResult.new("W9 Boss does not exist here!")
		if !boss.boss_mode_engaged: return Command.ExecuteResult.new("Battle hasn't started yet!")
		if boss.current_spell_used: boss.current_spell_used.FORCE_END_SPELLCARD = true
		boss.current_spell_index = boss.max_number_of_spellcards + 1
		boss.sc_actual_timer.stop()
		boss.end_spell_card()
		return Command.ExecuteResult.new("Success")
	else:
		if !is_instance_valid(boss) or !is_instance_valid(second_boss): return Command.ExecuteResult.new("Remilia or Marisa does not exist here!")
		if !handler.triggered: return Command.ExecuteResult.new("Battle hasn't started yet!")
		boss._battle_victory_sequence()
		second_boss._battle_victory_sequence()
		return Command.ExecuteResult.new("Success")
