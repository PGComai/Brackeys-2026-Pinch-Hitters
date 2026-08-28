extends PlayerState

func on_start(_msg := {}) -> void:
	player.play_animation("fall")

func on_end() -> void:
	player.land_particles()

func physics_update(delta: float) -> void:
	var dir := player.get_movement_axis()
	player.air_movement(delta, dir)

	if player.is_on_floor():
		if not is_zero_approx(dir):
			state_machine.change_state("Walk", {landed = true})
		else:
			state_machine.change_state("Idle")
	else:
		state_machine.change_state("Fall")