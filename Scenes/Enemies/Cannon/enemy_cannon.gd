class_name EnemyCannon
extends Enemy

@export var projectile_scene: PackedScene

@onready var visual: Node2D = $Visual
@onready var projectile_spawn: Node2D = $Visual/ProjectileSpawn
@onready var projectile_speed: float = 300.0

@onready var anim_player: AnimationPlayer = $Visual/AnimationPlayer

enum CannonTilt { FRONT, HALF_UP, UP }
var current_tilt := CannonTilt.FRONT


func fire() -> void:
	match current_tilt:
		CannonTilt.FRONT: anim_player.play("fire_front")
		CannonTilt.HALF_UP: anim_player.play("fire_half_up")
		CannonTilt.UP: anim_player.play("fire_up")


func random_tilt() -> void:
	set_tilt(CannonTilt.values().pick_random())


func set_tilt(tilt: CannonTilt) -> void:
	current_tilt = tilt
	match current_tilt:
		CannonTilt.FRONT: anim_player.play("front")
		CannonTilt.HALF_UP: anim_player.play("half_up")
		CannonTilt.UP: anim_player.play("up")


func spawn_projectile() -> void:
	if not projectile_scene or not projectile_scene.can_instantiate():
		push_error("EnemyCannon: No valid projectile_scene set!")
		return
	var dir := Vector2.ZERO
	match current_tilt:
		CannonTilt.FRONT:
			dir = Vector2.RIGHT
		CannonTilt.HALF_UP:
			dir = Vector2(1, -1).normalized()
		CannonTilt.UP:
			dir = Vector2.UP
	dir.x = dir.x * visual.scale.x
	
	var proj := projectile_scene.instantiate() as Projectile
	if not proj:
		push_error("EnemyCannon: projectile_scene is not type of Projectile!")
		return
	proj.velocity = projectile_speed * dir
	add_sibling(proj)


func _physics_process(delta: float) -> void:
	if touch_timer > 0.0:
		touch_timer -= delta
	
	
