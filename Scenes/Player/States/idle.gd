extends PlayerState

func on_start(_msg := {}) -> void:
	player.play_animation("idle")


func physics_update(delta: float) -> void:
	var dir := player.get_movement_axis()
	player.ground_movement(delta, dir)

	if player.climb_check():
		return

	if player.is_on_floor():
		if player.is_jump_pressed():
			state_machine.change_state("Jump")
		elif not is_zero_approx(dir):
			state_machine.change_state("Walk")
	else:
		state_machine.change_state("Fall")
