class_name EnemyStunState
extends EnemyState

@export var length: float = 3.0
## If unset, goes back to previous state.
@export var next_state: State

@export var anim_player: AnimationPlayer
@export var anim: StringName

var timer: float


func on_start(_msg := {}) -> void:
	timer = length
	if anim_player and anim:
		anim_player.play(anim)
	enemy.stars.visible = true


func on_end() -> void:
	enemy.stars.visible = false


func update(delta: float) -> void:
	timer -= delta
	if timer <= 0:
		if not next_state:
			state_machine.revert()
		else:
			state_machine.change_state(next_state.name)


func physics_update(_delta: float) -> void:
	enemy.velocity.x = 0