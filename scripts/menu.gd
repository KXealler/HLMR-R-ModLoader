extends Control

@onready var launch_button: Button = $VBoxContainer/PlayButton


func _ready() -> void:
	launch_button.pressed.connect(_on_launch_button_pressed)


func _on_launch_button_pressed() -> void:
	_launch_game()


func _launch_game() -> void:
	var game_path: String = SettingsManager.game_path
	if game_path == "" or not DirAccess.dir_exists_absolute(game_path):
		push_warning("Путь к игре не задан — откройте настройки.")
		return

	var exe_path: String = game_path.path_join("Hotline Miami Redux Redux.exe")

	if not FileAccess.file_exists(exe_path):
		push_warning("Файл не найден: " + exe_path)
		return

	var pid: int = OS.create_process(exe_path, [])
	if pid == -1:
		push_error("Не удалось запустить игру.")
	else:
		print("Игра запущена, PID = ", pid)


func _on_mods_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")


func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file("res://settings.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()
