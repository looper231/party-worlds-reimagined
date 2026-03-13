extends Label

func _ready() -> void:
	if !SecretsManager.get_secret("main clear"): 
		get_child(0).queue_free()
		self_modulate.a = 0.0
	else: for coin in get_children():
		if coin is Area2D: coin.queue_free()
	check_text()

func change_bonus_status() -> void:
	CustomGlobals.boss_should_give_pity = !CustomGlobals.boss_should_give_pity
	check_text()

func check_text() -> void:
	if CustomGlobals.boss_should_give_pity:
		text = "powerup bonus: on"
		add_theme_color_override("font_color", Color("76ff6d"))
	else:
		text = "powerup bonus: off"
		add_theme_color_override("font_color", Color("ff8e7e"))
		
