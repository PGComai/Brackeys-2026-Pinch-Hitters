extends Button
class_name InputBindingButton


signal rebound


var action_name: StringName
var action_event: InputEvent
var event_index: int
var binding := false
var stored_neighbors: Dictionary[String, NodePath] = {}


func _ready() -> void:
	if action_event:
		set_action_text()

	pressed.connect(_on_pressed)


func set_action_text() -> void:
	var event_text: String = action_event.as_text()
	event_text = event_text.trim_suffix(" - Physical")
	if event_text.begins_with("Joypad Button"):
		if event_text.contains("Xbox Share"):
			event_text = "Share/Mic"
		else:
			event_text = event_text.get_slice("(", 1)
			event_text = event_text.trim_suffix(")")
			if event_text.get_slice(",", 0):
				event_text = event_text.get_slice(",", 0)
	elif event_text.begins_with("Joypad Motion"):
		if event_text.contains("Right Trigger"):
			event_text = "Right Trigger"
		elif event_text.contains("Left Trigger"):
			event_text = "Left Trigger"
		else:
			event_text = event_text.get_slice("(", 1)
			event_text = event_text.get_slice(",", 0)
	text = event_text


func _input(event: InputEvent) -> void:
	if binding:
		if event is InputEventKey:
			if event.pressed:
				InputMap.action_erase_events(action_name)
				action_event = event
				prints("binding", action_name, "to", event.as_text())
				set_action_text()
				InputMap.action_add_event(action_name, event)
				rebound.emit()

				await get_tree().create_timer(0.05).timeout
				focus_neighbor_left = stored_neighbors["Left"]
				focus_neighbor_right = stored_neighbors["Right"]
				focus_neighbor_top = stored_neighbors["Top"]
				focus_neighbor_bottom = stored_neighbors["Bottom"]
				focus_next = stored_neighbors["Next"]
				focus_previous = stored_neighbors["Prev"]
				binding = false
				disabled = false
		else:
			focus_neighbor_left = stored_neighbors["Left"]
			focus_neighbor_right = stored_neighbors["Right"]
			focus_neighbor_top = stored_neighbors["Top"]
			focus_neighbor_bottom = stored_neighbors["Bottom"]
			focus_next = stored_neighbors["Next"]
			focus_previous = stored_neighbors["Prev"]
			binding = false
			disabled = false


func _on_pressed():
	stored_neighbors = {
		"Left": focus_neighbor_left,
		"Right": focus_neighbor_right,
		"Top": focus_neighbor_top,
		"Bottom": focus_neighbor_bottom,
		"Next": focus_next,
		"Prev": focus_previous,
	}
	binding = true
	disabled = true
	focus_neighbor_left = get_path()
	focus_neighbor_right = get_path()
	focus_neighbor_top = get_path()
	focus_neighbor_bottom = get_path()
	focus_next = get_path()
	focus_previous = get_path()
