extends Node

var pixel_perfect = false
var music_vol = 50
var sound_vol = 50

enum scale { ONE, TWO, THREE, FULLSCREEN }
var current_scale = scale.TWO

const SETTINGS_PATH = "user://settings.cfg"

func _ready() -> void:
	load_settings()

	var stretch = Window.CONTENT_SCALE_STRETCH_INTEGER if pixel_perfect else Window.CONTENT_SCALE_STRETCH_FRACTIONAL
	get_window().content_scale_stretch = stretch

	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Music"),
		linear_to_db(music_vol / 100.0)
	)
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("SFX"),
		linear_to_db(sound_vol / 100.0)
	)

	if not OS.has_feature("web"):
		set_scale(current_scale)

func save_settings() -> void:
	var cfg = ConfigFile.new()

	cfg.set_value("display", "pixel_perfect", pixel_perfect)
	cfg.set_value("display", "current_scale", current_scale)

	cfg.set_value("audio", "music_vol", music_vol)
	cfg.set_value("audio", "sound_vol", sound_vol)

	cfg.save(SETTINGS_PATH)


func load_settings() -> void:
	var cfg = ConfigFile.new()

	if cfg.load(SETTINGS_PATH) != OK:
		save_settings()
		return

	pixel_perfect = cfg.get_value("display", "pixel_perfect", pixel_perfect)
	current_scale = cfg.get_value("display", "current_scale", current_scale)

	music_vol = cfg.get_value("audio", "music_vol", music_vol)
	sound_vol = cfg.get_value("audio", "sound_vol", sound_vol)


func set_scale(s: scale) -> void:
	var def_scale = Vector2i(640, 352)

	current_scale = s

	match s:
		scale.ONE:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			get_window().size = def_scale

		scale.TWO:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			get_window().size = def_scale * 2

		scale.THREE:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			get_window().size = def_scale * 3

		scale.FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			save_settings()
			return

	get_window().move_to_center()
	save_settings()

func set_pixel_perfect(enabled: bool) -> void:
	pixel_perfect = enabled

	get_window().content_scale_stretch = (
		Window.CONTENT_SCALE_STRETCH_INTEGER
		if enabled
		else Window.CONTENT_SCALE_STRETCH_FRACTIONAL
	)

	save_settings()

func set_music_vol(value: float) -> void:
	music_vol = value

	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Music"),
		linear_to_db(music_vol / 100.0)
	)

	save_settings()

func set_sound_vol(value: float) -> void:
	sound_vol = value

	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("SFX"),
		linear_to_db(sound_vol / 100.0)
	)

	save_settings()

#func _input(event: InputEvent) -> void:
	#if OS.has_feature("pc"):
		#if Input.is_action_just_pressed("F1"):
			#set_scale(scale.ONE)
#
		#elif Input.is_action_just_pressed("F2"):
			#set_scale(scale.TWO)
#
		#elif Input.is_action_just_pressed("F3"):
			#set_scale(scale.THREE)
#
		#elif Input.is_action_just_pressed("F4"):
			#if current_scale == scale.FULLSCREEN:
				#set_scale(scale.THREE)
			#else:
				#set_scale(scale.FULLSCREEN)
#
	#if OS.has_feature("web"):
		#if Input.is_action_just_pressed("F4"):
			#if current_scale == scale.FULLSCREEN:
				#set_scale(scale.THREE)
			#else:
				#set_scale(scale.FULLSCREEN)
#
	#if Input.is_action_just_pressed("PixelPerfect"):
		#set_pixel_perfect(!pixel_perfect)
