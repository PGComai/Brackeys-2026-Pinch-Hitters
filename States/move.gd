class_name EnemyMoveState
extends EnemyState


@export var length: float = 2.0 
@export var direction: Vector2 = Vector2.RIGHT
@export var next_state: State
@export var interrupt: RayCast2D
@export var visual: Node2D


var timer: float


func on_start(_msg := {}) -> void:
	timer = length

func on_end(_msg := {}) -> void:
	timer = length


func update(delta: float) -> void:
	timer -= delta
	if timer <= 0 or (interrupt and interrupt.is_colliding()):
		state_machine.change_state(next_state.name)


func physics_update(_delta: float) -> void:
	enemy.velocity = direction.normalized() * enemy.patrol_speed 
	
	if visual:
		visual.scale.x = -1 if direction.x < 0 else 1
