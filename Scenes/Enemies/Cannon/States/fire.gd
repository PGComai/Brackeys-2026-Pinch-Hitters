extends EnemyState

@onready var cannon := owner as EnemyCannon

func on_start(_msg := {}) -> void:
	cannon.fire()
	cannon.anim_player.animation_finished.connect(func():
		if not state_machine.in_state(self):
			return
		var move_state := state_machine.get_node("Move") as EnemyMoveState
		move_state.direction = [Vector2.LEFT, Vector2.RIGHT].pick_random()
		move_state.length = randf_range(1.0, 3.0)
		cannon.random_tilt()
		state_machine.change_state("Wait")
		,CONNECT_ONE_SHOT)