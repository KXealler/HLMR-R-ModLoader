extends Node

signal game_path_changed(new_path: String)

const CONFIG_FOLDER_NAME = "HLMR-R_ModLoader"
const SETTINGS_FILE_NAME = "settings.txt"

const SECTION_TEXT = "text"
const KEY_LANG = "lang"
const DEFAULT_LANG = "en"

const SECTION_PATHS = "paths"
const KEY_GAME_PATH = "game_path"
const KEY_EXEC_FILE_PATH = "exec_file_path"
const DEFAULT_GAME_PATH = ""
const DEFAULT_EXEC_FILE_PATH = ""

const LEGACY_PATH_FILE_NAME = "path.txt"

var config_dir: String = ""
var settings_file: String = ""
var legacy_path_file: String = ""
var current_lang: String = DEFAULT_LANG
var game_path: String = DEFAULT_GAME_PATH
var exec_file_path: String = DEFAULT_EXEC_FILE_PATH


func _ready() -> void:
	_init_paths()
	_load_settings()
	_migrate_legacy_path()
	_apply_language()


func _init_paths() -> void:
	var base_dir: String
	if OS.get_name() == "Windows":
		var appdata = OS.get_environment("APPDATA")
		if appdata == "":
			appdata = OS.get_environment("USERPROFILE").path_join("AppData/Roaming")
		base_dir = appdata
	else:
		base_dir = OS.get_environment("HOME").path_join(".config")

	config_dir = base_dir.path_join(CONFIG_FOLDER_NAME)
	settings_file = config_dir.path_join(SETTINGS_FILE_NAME)
	legacy_path_file = config_dir.path_join(LEGACY_PATH_FILE_NAME)   # ← новое


func _load_settings() -> void:
	var cfg = ConfigFile.new()
	var err = cfg.load(settings_file)
	if err == OK:
		current_lang = cfg.get_value(SECTION_TEXT, KEY_LANG, DEFAULT_LANG)
		game_path = cfg.get_value(SECTION_PATHS, KEY_GAME_PATH, DEFAULT_GAME_PATH)
		exec_file_path = cfg.get_value(SECTION_PATHS, KEY_EXEC_FILE_PATH, DEFAULT_EXEC_FILE_PATH)
	else:
		current_lang = DEFAULT_LANG
		game_path = DEFAULT_GAME_PATH
		exec_file_path = DEFAULT_EXEC_FILE_PATH


func save_settings() -> void:
	if not DirAccess.dir_exists_absolute(config_dir):
		DirAccess.make_dir_recursive_absolute(config_dir)

	var cfg = ConfigFile.new()
	cfg.set_value(SECTION_TEXT, KEY_LANG, current_lang)
	cfg.set_value(SECTION_PATHS, KEY_GAME_PATH, game_path)   # ← новое
	cfg.set_value(SECTION_PATHS, KEY_EXEC_FILE_PATH, exec_file_path)
	cfg.save(settings_file)


func _apply_language() -> void:
	TranslationServer.set_locale(current_lang)


func set_language(lang_code: String) -> void:
	current_lang = lang_code
	_apply_language()
	save_settings()


func set_game_path(new_path: String) -> void:
	game_path = new_path
	save_settings()
	game_path_changed.emit(new_path)


func set_exec_file_path(new_path: String) -> void:
	exec_file_path = new_path
	save_settings()

func toggle_language() -> void:
	if current_lang == "ru":
		set_language("en")
	else:
		set_language("ru")

func get_mods_path() -> String:
	if game_path == "":
		return ""
	return game_path.path_join("Mods")

func _migrate_legacy_path() -> void:
	if game_path != "":
		return

	if not FileAccess.file_exists(legacy_path_file):
		return

	var file = FileAccess.open(legacy_path_file, FileAccess.READ)
	if file == null:
		return
	var old_path = file.get_as_text().strip_edges()
	file.close()

	if old_path != "" and DirAccess.dir_exists_absolute(old_path):
		game_path = old_path
		save_settings()

	DirAccess.remove_absolute(legacy_path_file)
