extends Control

const MODS_DIR_NAME = "Mods"
const TARGET_FILE_NAME = "data.win"

@onready var item_list: ItemList = $VBoxContainer/ItemList
@onready var load_button: Button = $VBoxContainer/Button
@onready var message_label: Label = $Label2
@onready var file_dialog: FileDialog = $FileDialog
@onready var info_label: Label = $Label

var mods_full_path: String = ""
var selected_mod_path: String = ""


func _ready() -> void:
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.title = "SELECT_FOLDER"
	file_dialog.dir_selected.connect(_on_file_dialog_dir_selected)

	item_list.item_selected.connect(_on_item_list_item_selected)
	load_button.pressed.connect(_on_load_button_pressed)

	SettingsManager.game_path_changed.connect(_on_game_path_changed)

	_check_path()




func _check_path() -> void:
	var p = SettingsManager.game_path
	if p == "" or not DirAccess.dir_exists_absolute(p):
		info_label.text = "SELECT_FOLDER"
		info_label.visible = true
		file_dialog.popup_centered()
		return

	mods_full_path = SettingsManager.get_mods_path()
	_refresh_mods_list()


func _on_file_dialog_dir_selected(dir: String) -> void:
	SettingsManager.set_game_path(dir)
	_check_path()


func _on_game_path_changed(_new_path: String) -> void:
	_check_path()


func _refresh_mods_list() -> void:
	info_label.visible = false

	item_list.clear()
	selected_mod_path = ""
	load_button.disabled = true

	if not DirAccess.dir_exists_absolute(mods_full_path):
		info_label.text = "MODS_FOLDER_NOT_FIND" + mods_full_path
		info_label.visible = true
		return

	var dir = DirAccess.open(mods_full_path)
	if dir == null:
		info_label.text = "CANT_OPEN_MODS_FOLDER"
		info_label.visible = true
		return

	var files = dir.get_files()

	if files.is_empty():
		info_label.text = "NO_FILES_IN_MODS"
		info_label.visible = true
		return

	for file_name in files:
		var display_name: String = file_name.get_basename()

		var index: int = item_list.add_item(display_name)

		item_list.set_item_metadata(index, file_name)

	if item_list.item_count > 0:
		item_list.ensure_current_is_visible()


func _on_item_list_item_selected(index: int) -> void:
	var real_file_name: String = item_list.get_item_metadata(index)
	selected_mod_path = mods_full_path.path_join(real_file_name)
	load_button.disabled = false


func _on_load_button_pressed() -> void:
	if selected_mod_path == "":
		return

	var target_path = SettingsManager.game_path.path_join(TARGET_FILE_NAME)

	var dir = DirAccess.open(SettingsManager.game_path)
	if dir == null:
		_show_message("NO_ACESS_TO_FOLDER", Color.RED)
		return

	var err = dir.copy(selected_mod_path, target_path)

	if err == OK:
		var display_name: String = selected_mod_path.get_file().get_basename()
		_show_message("MOD_LOADED", Color.GREEN)
		print("COPIED&RENAMED", target_path)
	else:
		#_show_message("ERR&CODE%d" % err, Color.RED)
		_show_message("ERR_WIHOUT_CODE", Color.RED)


func _show_message(text: String, color: Color = Color.WHITE) -> void:
	message_label.text = text
	message_label.modulate = color
	message_label.modulate.a = 0.0
	message_label.visible = true

	var tween = create_tween()
	tween.tween_property(message_label, "modulate:a", 1.0, 0.3).set_ease(Tween.EASE_OUT)
	tween.tween_interval(2.0)
	tween.tween_property(message_label, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN)
	tween.tween_callback(func(): message_label.visible = false)


func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://menu.tscn")
