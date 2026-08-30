@tool
extends PanelContainer
class_name ControlHint


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


func make_text() -> void:
	%LabelKey.text = key_text
	%LabelAction.text = action_text


func toggle_alternate_text(on: bool) -> void:
	if on:
		%LabelAction.text = alternate_text
	else:
		%LabelAction.text = action_text
