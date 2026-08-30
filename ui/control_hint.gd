@tool
extends PanelContainer
class_name ControlHint


const LABEL_SETTINGS_BIG = preload("uid://cdmnu0mw1xrpi")
const LABEL_SETTINGS_SMALL = preload("uid://cwcxp3tspegnw")


@export var key_text: String = "A":
	set(value):
		if key_text != value:
			key_text = value
			make_text()
@export var action_text: String = "Action":
	set(value):
		if action_text != value:
			action_text = value
			make_text()
@export var alternate_text: String = "Alt"
@export var small_text := false:
	set(value):
		if small_text != value:
			small_text = value
			make_text()


func make_text() -> void:
	%LabelKey.text = key_text
	%LabelAction.text = action_text
	if small_text:
		%LabelKey.label_settings = LABEL_SETTINGS_SMALL
	else:
		%LabelKey.label_settings = LABEL_SETTINGS_BIG


func toggle_alternate_text(on: bool) -> void:
	if on:
		%LabelAction.text = alternate_text
	else:
		%LabelAction.text = action_text
