extends Node

@export_category("Unlock Achievement")
@export var secrets: Array[String] = [""]
@export var show_toast: bool = true
@export var show_progress_toast: bool = true
@export var toast_text_overrides: Array[String] = [""]
@export_category("Progress Achievement")
@export var progress_by_id: String
@export var progress_to: int

func _ready() -> void:
	if secrets.size() > toast_text_overrides.size():
		toast_text_overrides.resize(secrets.size())

func unlock_secret(id: int = 0) -> void:
	if id < len(secrets):
		if secrets[id].is_empty(): return
		_make_split(id)
		SecretsManager.set_secret(secrets[id], true, true, show_toast, toast_text_overrides[id])


## "warped", "damaged", "died"
func unlock_if(conditions: PackedStringArray, id: int = 0) -> void:
	if ProfileManager.current_profile.data.get("started_from_middle", false):
		print("[Secrets] Profile was started from middle! Cancelling ID %d. (conditions)" % [id])
		return
	for i in conditions:
		if ProfileManager.current_profile.data.has(i):
			print("[Secrets] ID %d check failed (contains %s)" % [id, i])
			return
	unlock_secret(id)


func progress_secret(id: int = 0, replace_on_complete: bool = true) -> void:
	var new_secret = SecretsManager.get_secret(secrets[id])
	# Stop all further logic if already finished the progress
	if typeof(new_secret) == TYPE_BOOL && new_secret == true:
		print("[Secrets] ID %d has already been completed" % id)
		return
	if new_secret == null:
		new_secret = []
	
	# Ignore progression if already has it in user's saved array progress
	if new_secret.has(progress_by_id):
		print("[Secrets] ID %d already has %s" % [id, progress_by_id])
		return
	new_secret.append(progress_by_id)
	
	# Notify only if tweak is enabled
	var can_notify: bool = SettingsManager.get_tweak("secrets_notification", true)
	if SecretsManager.is_console_enabled(): can_notify = false
	
	# Finishing the progress, getting an achievement
	if len(new_secret) >= progress_to:
		_make_split(id, true)
		SecretsManager.set_secret(secrets[id], true if replace_on_complete else new_secret, true, false)
		if can_notify:
			SecretsManager.queue_achievement(secrets[id] if !toast_text_overrides[id] else toast_text_overrides[id])
		print("[Secrets] ID %d has been completed! total %d" % [id, progress_to])
		return
	
	# Progressing the achievement
	SecretsManager.set_secret(secrets[id], new_secret, true, false)
	if can_notify && show_progress_toast:
		var _current_progress: int = len(SecretsManager.secrets[secrets[id]])
		var _display_name = secrets[id] if !toast_text_overrides[id] else toast_text_overrides[id]
		SecretsManager.queue_achievement(
			"%s: %d / %d" % [_display_name, _current_progress, progress_to],
			tr("achievement progress"),
			false
		)
	print("[Secrets] ID %d progressed with %s out of total %d" % [id, progress_by_id, progress_to])

## This is adding garbage to profile for "unlock_if" method to prevent unlocking some secrets during gameplay
func add_shit_to_profile(data: String, value: bool = true) -> void:
	ProfileManager.current_profile.data[data] = value

func _make_split(id: int, no_check: bool = false) -> void:
	if SecretsManager.has_secret(secrets[id]) && !no_check:
		return


func _on_pipe_out_warp_ended(extra_arg_0: int) -> void:
	pass # Replace with function body.
