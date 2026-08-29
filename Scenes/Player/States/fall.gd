extends PlayerState

func on_start(_msg := {}) -> void:
	player.play_animation("fall")

func on_end() -> void:
	player.land_particles()

func physics_update(delta: float) -> void:
	var dir := player.get_movement_axis()
	player.air_movement(delta, dir)

	if player.climb_check():
		return

	if !Input.is_action_pressed("Jump"):
		player.velocity.y += player.gravity/50

	if player.is_on_floor():
		if not is_zero_approx(dir):
			state_machine.change_state("Walk", {landed = true})
		else:
			state_machine.change_state("Idle", {landed = true})
	else:
		state_machine.change_state("Fall")
