extends PlayerState

func on_start(_msg := {}) -> void:
	player.play_animation("climb_idle")


func physics_update(delta: float) -> void:
	var dir := player.get_movement_vector()

	# no accel/velocity while climbing
	player.velocity = Vector2.ZERO
	
	if not player.can_climb() or (player.is_on_floor() and not Input.is_action_pressed(&"Up")):
		state_machine.change_state("Idle")
		return

	if not dir.is_zero_approx():
		if not is_zero_approx(dir.x):
			player.set_facing(dir.x < 0)
		player.play_animation("climb")
		player.position += player.climb_speed * dir * Vector2(0.75, 1.0) * delta
	else:
		player.play_animation("climb_idle")

	if player.is_jump_pressed(): # hop off climbable
		if dir.y >= 0.1: # pressing down
			state_machine.change_state("Fall")
		else: # not pressing down
			player.jumped_off_climb()
			state_machine.change_state("Jump")
	
