extends ColorRect

@onready var lang_button: Button = $Button
@onready var lang_label: Label = $Button/Label


func _ready() -> void:
	lang_button.pressed.connect(_on_lang_button_pressed)
	_update_button_text()


func _on_lang_button_pressed() -> void:
	SettingsManager.toggle_language()
	_update_button_text()


func _update_button_text() -> void:
	if SettingsManager.current_lang == "ru":
		lang_label.text = "RU"
	else:
		lang_label.text = "EN"
