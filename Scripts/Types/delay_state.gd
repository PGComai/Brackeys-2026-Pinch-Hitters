@tool
class_name DelayState
extends State

@export var delay: float = 10.0:
	set(value):
		delay = value
		update_configuration_warnings()
@export var next_state: State:
	set(value):
		next_state = value
		update_configuration_warnings()

var timer: float

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := []
	if not next_state:
		warnings.append("Next state is not set!")
	return warnings


func on_start(_msg := {}) -> void:
	timer = delay


func on_end() -> void:
	pass


func update(delta: float) -> void:
	timer -= delta
	if timer <= 0:
		state_machine.change_state(next_state.name)


@warning_ignore("unused_parameter")
func physics_update(delta: float) -> void:
	pass


@warning_ignore("unused_parameter")
func input(event: InputEvent) -> void:
	pass


@warning_ignore("unused_parameter")
func unhandled_input(event: InputEvent) -> void:
	pass