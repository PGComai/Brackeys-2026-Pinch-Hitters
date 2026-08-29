extends HBoxContainer
class_name InputBinding


signal rebound


var action_name: StringName
var action_description: String


func _ready() -> void:
	var desc_label := Label.new()
	desc_label.text = action_description
	desc_label.custom_minimum_size.x = 64.0
	add_child(desc_label)
	#set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	var events: Array[InputEvent] = InputMap.action_get_events(action_name)
	print(events)

	var event: InputEvent = null
	if events.size() > 0:
		event = events[0]
	var new_button := InputBindingButton.new()
	new_button.event_index = 1
	new_button.action_event = event
	new_button.action_name = action_name
	new_button.rebound.connect(_on_rebound)
	add_child(new_button)
	#for i: int in mini(events.size(), 2):
		#var new_button := InputBindingButton.new()
		#new_button.event_index = i
		#new_button.action_name = action_name
		#new_button.rebound.connect(_on_rebound)
		#add_child(new_button)
	#if events.size() == 1:


func _on_rebound() -> void:
	rebound.emit()
