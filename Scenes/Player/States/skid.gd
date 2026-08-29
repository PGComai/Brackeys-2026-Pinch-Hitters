extends PlayerState

func on_start(_msg := {}) -> void:
	player.play_animation("skid")