class_name Projectile
extends Area2D

@export var velocity: Vector2 = Vector2.RIGHT
@export_range(0.0, 30.0, 0.5, "or_greater") var lifetime: float = 5.0
@export var damage: int = 1

@export var destroy_particles: PackedScene 

func _physics_process(delta: float) -> void:
	if has_overlapping_bodies():
		for body in get_overlapping_bodies():
			if body.has_method("damage"):
				body.damage(damage)
		destroy()

func destroy() -> void:
	if destroy_particles:
		var particles: CPUParticles2D = destroy_particles.instantiate()
		if is_instance_valid(particles):
			particles.emitting = true
			add_sibling(particles)
			particles.global_position = global_position
	queue_free()