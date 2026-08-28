extends PlayerState

func on_start(_msg := {}) -> void:
	player.play_animation("walk")


func physics_update(delta: float) -> void:
	var dir := player.get_movement_axis()
	player.ground_movement(delta, dir)

	if player.is_on_floor():
		if player.is_jump_pressed():
			state_machine.change_state("Jump")
		elif is_zero_approx(dir):
			state_machine.change_state("Idle")
	else:
		state_machine.change_state("Fall")
