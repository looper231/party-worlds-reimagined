extends Label

@export var text_keyboard: String = "to select a level, use corresponding number buttons."
@export var text_joypad: String = "to select a level, press up + %s."

func _ready() -> void:
	update_text()
	SettingsManager.settings_saved.connect(update_text)


func update_text() -> void:
	if SettingsManager.device_keyboard:
		text = tr(text_keyboard)
	else:
		var _events: Array[InputEvent] = InputMap.action_get_events(&"a_tab")
		var _ev = "tab button"
		for i in _events:
			if i is InputEventJoypadButton:
				_ev = "joy " + str(i.button_index)
		text = tr(text_joypad) % _ev
