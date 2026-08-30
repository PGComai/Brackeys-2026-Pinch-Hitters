extends CannonState

@export var aim_time: float = 2.0
@export var visual: Node2D
@export var aim_origin: Node2D

var timer: float
var target: Node2D

func on_start(msg := {}) -> void:
	timer = aim_time
	target = msg.get("target")
	if not target:
		state_machine.revert()
	if not aim_origin:
		aim_origin = cannon


func update(delta: float) -> void:
	timer -= delta
	if timer <= 0:
		state_machine.change_state("Fire")


func physics_update(_delta: float) -> void:
	enemy.velocity.x = 0
	if target:
		var direction := aim_origin.global_position.direction_to(target.global_position)
		var tilt := EnemyCannon.CannonTilt.FRONT
		if direction.y <= -0.7:
			tilt = EnemyCannon.CannonTilt.UP
		elif direction.y <= -0.4:
			tilt = EnemyCannon.CannonTilt.HALF_UP
		cannon.set_tilt(tilt)
		if visual:
			visual.scale.x = -1 if direction.x < 0 else 1
