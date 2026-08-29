extends VBoxContainer


const BINDING_FILE: String = "user://bindings.cfg"
const BINDING_FILE_VERSION: int = 0
const ACTION_NAMES: Array[StringName] = [
	&"Left",
	&"Right",
	&"Up",
	&"Down",
	&"Jump",
	&"Bubble"
]
const DEFAULT_KEYS: Dictionary[StringName, Key] = {
	&"Left": Key.KEY_LEFT,
	&"Right": Key.KEY_RIGHT,
	&"Up": Key.KEY_UP,
	&"Down": Key.KEY_DOWN,
	&"Jump": Key.KEY_Z,
	&"Bubble": Key.KEY_C
}
const DEFAULT_DESC: Dictionary[StringName, String] = {
	&"Left": "Move left",
	&"Right": "Move right",
	&"Up": "Up",
	&"Down": "Down",
	&"Jump": "Jump",
	&"Bubble": "Bubble"
}


func _ready() -> void:
	read_bindings()
	for an: StringName in DEFAULT_DESC.keys():
		var desc: String = DEFAULT_DESC[an]
		var new_binding := InputBinding.new()
		new_binding.action_name = an
		new_binding.action_description = desc
		new_binding.rebound.connect(_on_rebound)
		add_child(new_binding)


func _on_rebound() -> void:
	write_bindings()


func write_bindings() -> void:
	var file := FileAccess.open(BINDING_FILE, FileAccess.WRITE)
	
	file.store_8(BINDING_FILE_VERSION)
	
	for an: StringName in ACTION_NAMES:
		var event: InputEvent = InputMap.action_get_events(an)[0]
		print("writing event: %s" % event)
		print(OS.get_keycode_string(event.keycode))
		#file.store_string(OS.get_keycode_string(event.keycode))
		file.store_line(OS.get_keycode_string(event.keycode))
	
	file.close()


func read_bindings() -> void:
	if not FileAccess.file_exists(BINDING_FILE):
		InputMap.load_from_project_settings()
		return
	
	var file := FileAccess.open(BINDING_FILE, FileAccess.READ)
	
	var version: int = file.get_8()
	
	for an: StringName in ACTION_NAMES:
		var text_keycode: String = file.get_pascal_string()
		print(text_keycode)
		var input_key := InputEventKey.new()
		input_key.keycode = OS.find_keycode_from_string(text_keycode)
		set_action_event(an, input_key)
	
	file.close()


func set_action_event(action: StringName, event: InputEvent) -> void:
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
