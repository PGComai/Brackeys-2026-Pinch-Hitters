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


func make_text() -> void:
	%LabelKey.text = key_text
	%LabelAction.text = action_text
