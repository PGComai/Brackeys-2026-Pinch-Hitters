extends EnemyMoveState

@onready var cannon := owner as EnemyCannon

func on_start(_msg := {}) -> void:
	direction = [Vector2.LEFT, Vector2.RIGHT].pick_random()
	length = randf_range(1.0, 3.0)
	cannon.random_tilt()