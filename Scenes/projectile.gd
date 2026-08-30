class_name Projectile
extends Area2D

@export var velocity: Vector2 = Vector2.RIGHT
@export_range(0.0, 30.0, 0.5, "or_greater") var lifetime: float = 5.0
@export var damage: int = 1
@export var knockback: float = 0

@export var hit_sound: AudioStream
@export var destroy_particles: PackedScene 

func _process(delta: float) -> void:
	if lifetime > 0:
		lifetime -= delta
		if lifetime <= 0:
			destroy()

func _physics_process(delta: float) -> void:
	position += velocity * delta
	if has_overlapping_bodies():
		for body in get_overlapping_bodies():
			if body.has_method("hit"):
				var knock_vec := Vector2.ZERO
				if knockback > 0:
					knock_vec = global_position.direction_to(body.global_position) * knockback
					knock_vec += velocity / 3.0
				body.hit(damage, velocity)
		destroy()

func destroy() -> void:
	if destroy_particles:
		var particles: CPUParticles2D = destroy_particles.instantiate()
		if is_instance_valid(particles):
			particles.emitting = true
			add_sibling(particles)
			particles.global_position = global_position
	if hit_sound:
		var asp := AudioStreamPlayer2D.new()
		asp.stream = hit_sound
		asp.bus = "SFX"
		add_sibling(asp)
		asp.global_position = global_position
		asp.play()
		asp.finished.connect(asp.queue_free)
	queue_free()