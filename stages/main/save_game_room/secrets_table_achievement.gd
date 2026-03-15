extends HBoxContainer

@export var secret_id: String
@export var progress_to: int = 0
@export var hidden_on_init: bool = false

var original_text: String

func _ready() -> void:
	var label = get_child(0)
	original_text = label.text
	#if replace_with_kevin:
	#	var encount = SecretsManager.get_secret("hint_guy_encountered")
	#	original_text = tr(original_text) % (tr("kevin") if encount else "?????")
	#	label.text = original_text
	
	if hidden_on_init:
		label.text = tr("<hidden achievement>")

func show_hidden() -> void:
	await get_tree().physics_frame
	get_child(0).text = original_text
	show()
