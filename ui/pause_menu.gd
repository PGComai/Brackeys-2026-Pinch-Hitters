extends PanelContainer
class_name PauseMenu


signal resume_requested
signal reset_requested
signal quit_requested


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
