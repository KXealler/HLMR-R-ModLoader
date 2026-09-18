extends Control

@onready var path_label: Label = $ColorRect/PathLabel
@onready var file_dialog: FileDialog = $FileDialog


func _ready() -> void:
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.title = "SELECT_FOLDER"

	file_dialog.dir_selected.connect(_on_file_dialog_dir_selected)
	SettingsManager.game_path_changed.connect(_on_game_path_changed)

	path_label.mouse_filter = Control.MOUSE_FILTER_STOP
	path_label.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	path_label.gui_input.connect(_on_path_label_gui_input)

	_refresh_label()


func _refresh_label() -> void:
	var p: String = SettingsManager.game_path
	if p == "" or not DirAccess.dir_exists_absolute(p):
		path_label.text = "PATH_NOT_SET"
	else:
		path_label.text = p


func _on_path_label_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			file_dialog.popup_centered()


func _on_file_dialog_dir_selected(dir: String) -> void:
	SettingsManager.set_game_path(dir)
	_refresh_label()


func _on_game_path_changed(_new_path: String) -> void:
	_refresh_label()


func _on_x_pressed() -> void:
	get_tree().change_scene_to_file("res://menu.tscn")
