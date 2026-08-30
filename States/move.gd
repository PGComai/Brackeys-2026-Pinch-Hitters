class_name EnemyMoveState
extends EnemyState


@export var length: float = 2.0 
@export var direction: Vector2 = Vector2.RIGHT
@export var next_state: State
@export var interrupt: RayCast2D

var timer


func on_start(_msg := {}) -> void:
	timer = length


func update(delta: float) -> void:
	timer -= delta
	if timer <= 0 or (interrupt and interrupt.is_colliding()):
		state_machine.change_state(next_state.name)


func physics_update(delta: float) -> void:
	enemy.velocity = direction.normalized() * enemy.patrol_speed 
	enemy.move_and_slide()

