extends PanelContainer
class_name PauseMenu


const CONFIG_FILE: String = "config.cfg"


signal resume_requested
signal reset_requested
signal quit_requested


var vol_slider := HSlider.new()
var vol_label := Label.new()
var volume: float = 100.0:
	set(value):
		volume = clampf(value, 0.0, 100.0)


@onready var v_box_container: VBoxContainer = $VBoxContainer


func _ready() -> void:
	create_volume_slider()
	read_config()
	apply_config()


func activate() -> void:
	visible = true
	%ButtonResume.grab_focus()


func deactivate() -> void:
	visible = false


func _on_button_resume_pressed() -> void:
	resume_requested.emit()


func _on_button_reset_pressed() -> void:
	reset_requested.emit()


func _on_button_quit_pressed() -> void:
	quit_requested.emit()


func create_volume_slider() -> void:
	v_box_container.add_child(vol_slider)
	v_box_container.add_child(vol_label)
	
	vol_slider.max_value = 100.0
	vol_slider.min_value = 0.0
	vol_slider.step = 10.0
	
	vol_slider.value_changed.connect(_on_vol_changed)
	vol_slider.drag_ended.connect(_on_vol_finished)


func _on_vol_changed(value: float) -> void:
	volume = value
 

func _on_vol_finished(value_changed: bool) -> void:
	if value_changed:
		write_config()
		apply_config()


func write_config() -> void:
	var file := FileAccess.open(CONFIG_FILE, FileAccess.WRITE)
	
	file.store_line(str(int(volume)))
	
	file.close()


func read_config() -> void:
	if not FileAccess.file_exists(CONFIG_FILE):
		write_config()
		return
	var file := FileAccess.open(CONFIG_FILE, FileAccess.READ)
	
	var vol_line: String = file.get_line()
	if not vol_line.is_valid_int():
		vol_line = "100" 
	volume = float(vol_line.to_int())
	
	file.close()


func apply_config() -> void:
	vol_slider.set_value_no_signal(volume)
	vol_label.text = "Vol: %s" % int(volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume_scale(volume))
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), is_zero_approx(volume))


static func volume_scale(vol_lin: float) -> float:
	return clampf(remap(vol_lin, 0.0, 100.0, -40.0, 0.0), -40.0, 0.0)
