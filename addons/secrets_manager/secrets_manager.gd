extends CanvasLayer

const secrets_path = "user://achievements.thss"
const SECRET_NOTIFICATION = preload("res://addons/secrets_manager/achievement.wav")
const NOTIFICATION = preload("res://addons/secrets_manager/notification.tscn")
const NOTIFICATION_ERROR = preload("res://addons/secrets_manager/notification_error.wav")

var secrets: Dictionary = {}
var toast_queue: Array[Array] = []

var _save_queued: bool
var _is_free: bool = true
var _has_cheated: bool = false
var _tween_game_save: Tween

@onready var label: Label = $AchievementText
@onready var ninepatch: NinePatchRect = $AchievementText/NinePatchRect
@onready var marker_2d: Marker2D = $Marker2D
#@onready var saved: Control = $Saved

signal secret_set(_name: String)

func _init() -> void:
	var new_save_path = OS.get_user_data_dir().path_join("saves")
	if DirAccess.dir_exists_absolute(new_save_path):
		return

func _ready() -> void:
	#saved.modulate.a = 0
	load_secrets()
	reparent.call_deferred(GlobalViewport.vp, false)
	Data.life_added.connect(func():
		if Data.values.lives >= 99:
			set_secret("got 100 extra lives at once", true)
	)
	await get_tree().physics_frame
	
	return
	# Notifications
	Thunder._connect(SkinsManager.skins_loaded, _on_skins_reloaded)
	Thunder._connect(Thunder.autosplitter.connected, _on_asws_connected)
	Thunder._connect(Thunder.autosplitter.restarting, notify.bind("Auto Splitter Restarting..."))
	#if Console.allow_developer_commands:
	#	pl_speed.show()
	#	pl_speed.process_mode = Node.PROCESS_MODE_PAUSABLE


func _physics_process(delta: float) -> void:
	if _save_queued:
		_save_queued = false
		SettingsManager.save_data(secrets, secrets_path, "Achievements")
	if _is_free && toast_queue.size() > 0:
		_is_free = false
		var _toast = toast_queue.pop_back()
		show_achievement(_toast.pop_front(), _toast.pop_front(), _toast.pop_front())


func set_secret(secret: String, value: Variant, save: bool = true, show_toast: bool = true, toast_text: String = "") -> void:
	if secret in secrets && (
		typeof(secrets[secret]) == TYPE_BOOL &&
		typeof(value) == TYPE_BOOL &&
		secrets[secret] == value
	):
		print("[Secrets Manager] Save cancelled, %s already exists!" % secret)
		return
	if is_console_enabled():
		print("[Secrets Manager] Console tweak is enabled! Didn't set %s to %s" % [str(value), secret])
		return
	if !secret in secrets && show_toast && SettingsManager.get_tweak("secrets_notification", true):
		queue_achievement(secret if !toast_text else toast_text)
	secrets[secret] = value
	secret_set.emit(secret)
	if save: save_secrets()

func has_secret(secret: String) -> bool:
	return secret in secrets && secrets[secret]

func get_secret(secret: String) -> Variant:
	if secret in secrets:
		return secrets[secret]
	return null


func is_endgame() -> bool:
	return has_secret("story mode completed")


func queue_achievement(text: String, title: String = tr("achievement unlocked!"), emit_sound: bool = true) -> void:
	var _toast := [text, title, emit_sound]
	toast_queue.append(_toast)


func show_achievement(text: String, title: String, emit_sound: bool) -> void:
	if emit_sound:
		Audio.play_1d_sound(SECRET_NOTIFICATION, true, { ignore_pause = true, bus = "1D Sound" })
	label.text = ""
	label.size.x = 192
	label.position.y = marker_2d.position.y + label.size.y + 8
	label.modulate.a = 1.0
	label.modulate.g = 1.0
	label.modulate.b = 1.0
	label.text = "%s
%s" % [title, text]
	var tw = create_tween().set_parallel()
	tw.tween_property(label, "position:y", marker_2d.position.y, 0.8)
	tw.tween_property(label, "modulate:a", marker_2d.modulate.a, 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(5.0, true, false, true).timeout
	if len(toast_queue) == 0:
		tw = create_tween()
		tw.tween_property(label, "modulate:a", 0.0, 2.0)
	
	_is_free = true


func show_failure(text: String, title: String = tr("achievement failed")) -> void:
	if is_console_enabled() || !SettingsManager.get_tweak("secrets_notification", false):
		return
	Audio.play_1d_sound(NOTIFICATION_ERROR, true, {ignore_pause = true, volume = -4, bus = "1D Sound" })
	_is_free = false
	label.text = ""
	label.size.x = 192
	label.position.y = marker_2d.position.y + label.size.y + 8
	label.modulate.a = 1.0
	label.modulate.g = 0.4
	label.modulate.b = 0.333
	label.text = "%s
%s" % [title, text]
	var tw = create_tween().set_parallel()
	tw.tween_property(label, "position:y", marker_2d.position.y, 0.8)
	tw.tween_property(label, "modulate:a", marker_2d.modulate.a, 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(5.0, true, false, true).timeout
	if len(toast_queue) == 0:
		tw = create_tween()
		tw.tween_property(label, "modulate:a", 0.0, 2.0)
	
	_is_free = true


func notify(text: String, outline_color: Color = Color(0.505, 1, 0.34)) -> void:
	return
	var notif = NOTIFICATION.instantiate()
	var panel_c: PanelContainer = notif.get_child(0)
	var styleb: StyleBoxFlat = panel_c.get_theme_stylebox(&"panel").duplicate()
	styleb.border_color = outline_color
	panel_c.add_theme_stylebox_override(&"panel", styleb)
	notif.get_child(0).get_child(0).get_child(0).text = text
	%NotificationBox.add_child(notif)
	notif.modulate.a = 0.0
	var __tw = notif.create_tween()
	__tw.tween_property(notif, "modulate:a", 1.0, 0.3)
	__tw.tween_interval(3.0)
	__tw.tween_property(notif, "modulate:a", 0.0, 1.0)
	__tw.tween_callback(notif.queue_free)

func notify_error(text: String) -> void:
	text = "Error: " + text
	Audio.play_1d_sound(NOTIFICATION_ERROR, true, { ignore_pause = true, bus = "1D Sound" })
	notify(text, Color.FIREBRICK)
	
func notify_warn(text: String) -> void:
	text = "Warning: " + text
	Audio.play_1d_sound(NOTIFICATION_ERROR, true, { ignore_pause = true, bus = "1D Sound" })
	notify(text, Color.YELLOW)


func _on_skins_reloaded() -> void:
	notify(tr("Skins reloaded!"))

func _on_asws_connected() -> void:
	notify(tr("Auto Splitter Ready!"))
	Thunder._connect(Thunder.autosplitter.closed, notify_warn.bind("Auto Splitter Offline"))


func load_secrets() -> void:
	var data: Dictionary = SettingsManager.load_data(secrets_path, "Achievements")
	if data.is_empty():
		print("[Secrets Manager] No achievements found.")
		return
	
	secrets = data
	print("[Secrets Manager] Achievements loaded.")

func save_secrets() -> void:
	_save_queued = true


func game_saved() -> void:
	return
	if ProfileManager.current_profile.name == "debug":
		return
	if _tween_game_save && _tween_game_save.is_valid():
		_tween_game_save.kill()
	_tween_game_save = create_tween().set_trans(Tween.TRANS_SINE)
	#_tween_game_save.tween_property(saved, "modulate:a", 1.0, 0.3).from(0.0)
	_tween_game_save.tween_interval(3.0)
	#_tween_game_save.tween_property(saved, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN)


func set_save_icon():
	if SettingsManager.get_tweak("save_icon", false):
		Thunder._connect(ProfileManager.current_profile_saved, game_saved)
	else:
		Thunder._disconnect(ProfileManager.current_profile_saved, game_saved)


func is_console_enabled() -> bool:
	return SettingsManager.get_tweak("console_enabled", false) || Console.command_executed || _has_cheated
