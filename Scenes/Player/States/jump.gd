extends PlayerState

func on_start(_msg := {}) -> void:
	player.play_animation("jump")
	player.velocity.y = player.JUMP_VELOCITY


func physics_update(delta: float) -> void:
	var dir := player.get_movement_axis()
	player.air_movement(delta, dir)

	if player.velocity.y > 0:
		state_machine.change_state("Fall")
