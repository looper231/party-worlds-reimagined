extends CanvasLayer
class_name GenericBossHUD

const SPELL_CUTIN = preload("res://objects/boss_touhou/boss_dlc/components/spell_cutin_generic.tscn")

@export var y_offset = 0
@export var append_attack_count_to_name: bool = true
@export var main_boss_name: String = "DEFAULT BOSS"
@export var spellcard_cutin = SPELL_CUTIN

@onready var boss_name_label: Label = $BossName
@onready var spellcard_count: TextureRect = $BossName/SpellCardCount
@onready var spellcard_name: Label = $SpellCardName
@onready var spellcard_timecounter: Label = $TimeCounter
@onready var spellcard_pity_bonus: Label = $PowerBonus
@onready var init_pos_y: float = boss_name_label.get_viewport_transform().affine_inverse().origin.y - 256 + y_offset
@onready var to_pos_y: float = boss_name_label.position.y + y_offset
@onready var default_count_size: Vector2 = spellcard_count.size
var tween: Tween
var tween_spellname: Tween
@onready var timer_spellname: Timer = $Timer
var boss_entity
var spell_cutin_portrait

func _ready() -> void:
	boss_name_label.text = main_boss_name
	boss_name_label.position.y = init_pos_y
	spellcard_pity_bonus.scale.y = 0.0
	spellcard_name.modulate.a = 0.0

func appear_animation() -> void:
	spellcard_name.position += Vector2(640.0, 336.0)
	spellcard_name.modulate.a = 1.0
	boss_name_label.modulate.a = 0.0
	boss_name_label.position.y = to_pos_y
	spellcard_timecounter.appear()
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(boss_name_label, "modulate:a", 1.0, 0.2)

func disappear() -> void:
	spellcard_timecounter.disappear()
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(boss_name_label, "modulate:a", 0.0, 0.2)
	tween.tween_callback(queue_free)

func spell_card_changed(spell_cards_left: int) -> void:
	if !is_instance_valid(spellcard_count): return
	
	if spell_cards_left > 0 && boss_name_label.position.y != to_pos_y:
		if !tween || !tween.is_valid():
			tween = create_tween()
			tween.tween_property(boss_name_label, "position:y", to_pos_y, 1)
	elif spell_cards_left <= -1 && boss_name_label.position.y != init_pos_y:
		if tween && tween.is_valid(): tween.kill()
		tween = create_tween()
		tween.tween_property(boss_name_label, "position:y", init_pos_y, 1)
	
	if !append_attack_count_to_name:
		if spell_cards_left <= 0: spellcard_count.visible = false
		else: spellcard_count.visible = true
		spellcard_count.size.x = default_count_size.x * spell_cards_left
	else:
		if spellcard_count.visible: spellcard_count.visible = false
		var spell_stars: String = ""
		for i in spell_cards_left:
			spell_stars += "*"
		boss_name_label.text = main_boss_name + " " + spell_stars

# Hardcoded because Godot refuses to work properly for some reason
func spell_card_declare_name(the_name: String = "Default Sign \"Default Name\"", do_cutin: bool = true) -> void:
	#print("Spellcard: " + the_name)
	if do_cutin: _spell_cutin_anim()
	_spell_name_anim(the_name)

func _spell_cutin_anim() -> void:
	if is_instance_valid(spell_cutin_portrait):
		spell_cutin_portrait.queue_free()
	spell_cutin_portrait = spellcard_cutin.instantiate()
	spell_cutin_portrait.starting_pos = Vector2(1280.0, 300.0)
	spell_cutin_portrait.target_pos = Vector2(500.0, 300.0)
	add_child(spell_cutin_portrait)
	spell_cutin_portrait.z_index = -50

func _spell_name_anim(the_name: String) -> void:
	spellcard_name.text = the_name
	if is_instance_valid(tween_spellname): tween_spellname.kill()
	if !timer_spellname.is_stopped(): timer_spellname.stop()
	spellcard_name.position = Vector2(0.0, 71.0) + Vector2(640.0, 336.0)
	tween_spellname = get_tree().create_tween()
	tween_spellname.set_trans(Tween.TRANS_CIRC)
	tween_spellname.set_ease(Tween.EASE_OUT)
	tween_spellname.tween_property(spellcard_name, "position:x", 0.0, 1.0)
	tween_spellname.tween_callback(func() -> void:
		timer_spellname.start(0.3)
		timer_spellname.timeout.connect(func() -> void:
			if is_instance_valid(tween_spellname): tween_spellname.kill()
			tween_spellname = get_tree().create_tween()
			tween_spellname.set_trans(Tween.TRANS_CIRC)
			tween_spellname.set_ease(Tween.EASE_OUT)
			tween_spellname.tween_property(spellcard_name, "position:y", 71.0, 0.6)
			))

func spell_card_undeclare_name() -> void:
	if tween_spellname: tween_spellname.kill()
	if !timer_spellname.is_stopped(): timer_spellname.stop()
	tween_spellname = get_tree().create_tween()
	tween_spellname.tween_property(spellcard_name, "position:x", 640.0, 0.3)

func spell_card_pity_bonus() -> void:
	spellcard_pity_bonus.scale.y = 0.0
	var tw1 = get_tree().create_tween()
	tw1.tween_property(spellcard_pity_bonus, "scale:y", 1.0, 0.25)
	await get_tree().create_timer(2.0, false).timeout
	var tw2 = get_tree().create_tween()
	tw2.tween_property(spellcard_pity_bonus, "scale:y", 0.0, 0.25)
