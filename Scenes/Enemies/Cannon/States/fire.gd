extends CannonState

@export var next_state: State

func on_start(_msg := {}) -> void:
	cannon.fire()
	if next_state:
		cannon.anim_player.animation_finished.connect(func(anim_name: StringName):
			if not state_machine.in_state(self) or not anim_name.begins_with("fire_"):
				return
			state_machine.change_state(next_state.name)
			,CONNECT_ONE_SHOT)


func physics_update(_delta: float) -> void:
	enemy.velocity.x = 0