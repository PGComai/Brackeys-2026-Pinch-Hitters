class_name PlayerState
extends State

@onready var player := state_machine.get_parent() as Player

@warning_ignore("unused_parameter")
func on_start(msg := {}) -> void:
	pass

func on_end() -> void:
	pass

@warning_ignore("unused_parameter")
func update(delta: float) -> void:
	pass

@warning_ignore("unused_parameter")
func physics_update(delta: float) -> void:
	pass

@warning_ignore("unused_parameter")
func input(event: InputEvent) -> void:
	pass

@warning_ignore("unused_parameter")
func unhandled_input(event: InputEvent) -> void:
	pass