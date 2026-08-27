class_name Player
extends CharacterBody2D

@export var gravity: float = 500.0
@export var inverted = false

@export var on_the_space_level = false
@onready var collision_shape_2d_2: CollisionShape2D = $CollisionShape2D2

var hp = 5

var direction := Input.get_axis("Left", "Right")

@export var speed: float = 250.0
@export var acceleration: float = 800.0
@export var friction: float = 1200.0
@export var air_friction: float = 80.0
const JUMP_VELOCITY = -350
const JUMP_CUT = 2.5

@export var has_hammer = true
@export var hammer_damage = 1
@export var hammer_knockback = 300.0

@export var invincibility_duration: float = 1.2
@export var blink_interval: float = 0.08

@export var hitstop_duration: float = 0.1
@export var hitstop_scale: float = 0.05

const NO_AIM = -999.0

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var fish_helper: Node2D = $FishHelper
@onready var fish_sprite: AnimatedSprite2D = $FishHelper/FishSprite

@onready var death_animation: AnimationPlayer = $DeathAnimation

@onready var jump_sound: AudioStreamPlayer = $JumpSound
@onready var land_sound: AudioStreamPlayer2D = $SFX/LandSound
@onready var hurt_sound: AudioStreamPlayer2D = $SFX/HurtSound

@onready var game_over: AudioStreamPlayer = $SFX/GameOver

const LANDPARTICLES = preload("res://Scenes/Player/land_particles.tscn")
const PROJBUBBLE = preload("res://Scenes/Player/proj_bubble.tscn")

enum State { IDLE, WALKING, JUMPING, FALLING, SKIDDING }
var current_state = State.IDLE
var previous_state = State.IDLE
var was_on_floor = true

@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_buffer_timer: Timer = $JumpBufferTimer

@onready var hammer_time: Node2D = $HammerTime
@onready var hammer_hitbox: Area2D = $HammerTime/HammerHitbox

@onready var camera: Camera2D = $Camera2D

var frames := 0

@onready var spawn_point: Node2D = $"../SpawnPoint"
@onready var user_interface: CanvasLayer = $"../UserInterface"
@onready var secret_cam: Camera2D = $SecretCam
@onready var music_player: AudioStreamPlayer = $"../MusicPlayer"

var is_invincible: bool = false
var invincibility_timer: float = 0.0
var blink_timer: float = 0.0
var blink_tween: Tween

var hitstop_active: bool = false

func _ready() -> void:
	animate()
	was_on_floor = is_on_floor()

func _physics_process(delta: float) -> void:
	var gravity_force := gravity if !inverted else -gravity

	if inverted:
		up_direction = Vector2.DOWN
	else:
		up_direction = Vector2.UP

	if not is_on_floor():
		if on_the_space_level:
			if not Input.is_action_just_pressed("Jump"):
				velocity.y = lerp(velocity.y, 0.0, 0.1)
				velocity.y += gravity_force * JUMP_CUT * delta
			else:
				velocity.y += gravity_force * delta
			velocity.y = clamp(velocity.y, -240, 240)
		else:
			if velocity.y < 0 and not Input.is_action_pressed("Jump"):
				velocity.y = lerp(velocity.y, 0.0, 0.1)
				velocity.y += gravity_force * JUMP_CUT * delta
			else:
				velocity.y += gravity_force * delta
			if gravity_force > 0:
				velocity.y = min(velocity.y, 240)
			else:
				velocity.y = max(velocity.y, -240)

		if (!inverted and is_on_ceiling()) or (inverted and is_on_floor()):
			velocity.y += sign(gravity_force) * 50

	movement(delta)
	jump()
	move_and_slide()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		if collider is RigidBody2D:
			collider.apply_central_impulse(-collision.get_normal() * 30)

	if was_on_floor and not is_on_floor():
		coyote_timer.start()

	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider.is_in_group("deadly"):
			die()
			return

	determine_state()
	previous_state = current_state
	animate()
	update_invincibility(delta)

	was_on_floor = is_on_floor()
	frames += 1

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Bubble"):
		fish_sprite.frame = 1
		fisshe_bubble(-1 if sprite.flip_h else 1)
	else:
		fish_sprite.frame = 0
	if Input.is_action_just_pressed("Restart"):
		get_tree().reload_current_scene()
	if not has_hammer:
		return
	if Input.is_action_just_pressed("Fire"):
		hammer_hit()

func determine_state():
	if not is_on_floor():
		current_state = State.FALLING if velocity.y > 0 else State.JUMPING
		return
	if abs(velocity.x) > 0:
		current_state = State.WALKING
	else:
		current_state = State.IDLE

func movement(delta):
	var direction := Input.get_axis("Left", "Right")

	if direction < 0:
		sprite.flip_h = true
	elif direction > 0:
		sprite.flip_h = false

	update_hammer_rotation()

	if direction:
		velocity.x += direction * acceleration * delta
		velocity.x = clamp(velocity.x, -speed, speed)
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, friction * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, air_friction * delta)

func update_hammer_rotation() -> void:
	var up := Input.is_action_pressed("Up")
	var down := Input.is_action_pressed("Down")
	var left := Input.is_action_pressed("Left")
	var right := Input.is_action_pressed("Right")

	var angle := get_aim_angle(up, down, left, right)

	if angle == NO_AIM:
		hammer_time.rotation = 0
		hammer_time.scale.x = -1 if sprite.flip_h else 1
	else:
		hammer_time.rotation = angle
		hammer_time.scale.x = 1

func get_aim_angle(up: bool, down: bool, left: bool, right: bool) -> float:
	#if up and right:
		#return deg_to_rad(-45)
	#elif up and left:
		#return deg_to_rad(-135)
	#elif down and right:
		#return deg_to_rad(45)
	#elif down and left:
		#return deg_to_rad(135)
	if up:
		return deg_to_rad(-90)
	#elif down:
		#return deg_to_rad(90)
	elif left:
		return deg_to_rad(180)
	elif right:
		return deg_to_rad(0)
	else:
		return NO_AIM

func get_hammer_aim_direction() -> Vector2:
	var facing_sign := hammer_time.scale.x
	var local_dir := Vector2(facing_sign, 0).rotated(hammer_time.rotation)
	return local_dir.normalized()

func hammer_hit() -> void:
	if not hammer_hitbox:
		return

	var aim_direction: Vector2 = get_hammer_aim_direction()
	var hit_something := false

	var bodies := hammer_hitbox.get_overlapping_bodies()
	for body in bodies:
		if body == self:
			continue

		if body.is_in_group("hittable"):
			if body.has_method("hit"):
				body.hit(hammer_damage, aim_direction * hammer_knockback)
				hit_something = true
			elif body is RigidBody2D:
				body.apply_central_impulse(aim_direction * hammer_knockback)
				hit_something = true

	var areas := hammer_hitbox.get_overlapping_areas()
	for area in areas:
		if area.is_in_group("hittable"):
			if area.has_method("hit"):
				area.hit(hammer_damage, aim_direction * hammer_knockback)
				hit_something = true

	if hit_something:
		apply_hitstop()

func apply_hitstop() -> void:
	if hitstop_active:
		return
	hitstop_active = true
	Engine.time_scale = hitstop_scale
	var timer := get_tree().create_timer(hitstop_duration, true, false, true)
	timer.timeout.connect(func():
		Engine.time_scale = 1.0
		hitstop_active = false
	)

func jump():
	if not on_the_space_level:
		if Input.is_action_just_pressed("Jump"):
			jump_buffer_timer.start()

	if jump_buffer_timer.time_left > 0:
		if is_on_floor() or coyote_timer.time_left > 0:
			velocity.y = JUMP_VELOCITY
			jump_buffer_timer.stop()
			coyote_timer.stop()
			jump_sound.play()

func land_particles() -> void:
	Input.start_joy_vibration(0, 0.2, 0.0, 0.2)
	var p = LANDPARTICLES.instantiate()
	get_parent().add_child(p)
	if inverted:
		p.global_position = global_position + Vector2(0, -32)
	else:
		p.global_position = global_position + Vector2(0, +32)
	p.z_index = z_index + 1
	p.emitting = true

func animate():
	fisshe_animate()
	
	var just_landed = is_on_floor() and not was_on_floor and frames > 2
	if just_landed:
		animation.play("land")
		land_particles()

	match current_state:
		State.IDLE:
			sprite.play("idle")
		State.WALKING:
			sprite.play("walk")
		State.JUMPING:
			sprite.play("jump")
		State.FALLING:
			sprite.play("fall")

func hit(damage: int, knockback: Vector2) -> void:
	if is_invincible:
		return

	if hp > 1:
		hp -= 1
		start_invincibility()
	else:
		die()

	var push_dir := signf(knockback.x) if knockback.x != 0 else (-1.0 if sprite.flip_h else 1.0)
	velocity.x = push_dir * abs(hammer_knockback)
	#hurt_sound.play()

func start_invincibility() -> void:
	is_invincible = true
	invincibility_timer = invincibility_duration

	if blink_tween:
		blink_tween.kill()

	blink_tween = create_tween()
	blink_tween.set_loops()
	blink_tween.tween_property(sprite, "self_modulate", Color.DIM_GRAY, blink_interval)
	blink_tween.tween_property(sprite, "self_modulate", Color.WHITE, blink_interval)

func update_invincibility(delta: float) -> void:
	if not is_invincible:
		return

	invincibility_timer -= delta

	if invincibility_timer <= 0.0:
		is_invincible = false
		if blink_tween:
			blink_tween.kill()
		sprite.self_modulate = Color.WHITE

func die() -> void:
	get_tree().reload_current_scene()

	#hurt_sound.play()
	#animation.play("RESET")
	#death_animation.play("death")
	#game_over.play()
	#
	#modulate = Color.DIM_GRAY
	#
	#get_tree().current_scene.pausable = false
	#get_tree().paused = true

func _on_death_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		if spawn_point:
			animation.play("RESET")
			death_animation.play("RESET")

			if music_player:
				music_player.stream_paused = true

			get_tree().current_scene.pausable = true
			get_tree().paused = false

			modulate = Color.WHITE

			position = spawn_point.position
			inverted = false
			velocity = Vector2(0, 0)
		else:
			get_tree().paused = false
			get_tree().reload_current_scene()

func fisshe_bubble(direction):
	var bubble = PROJBUBBLE.instantiate()
	bubble.direction = direction
	bubble.z_index = z_index - 1
	get_parent().add_child(bubble)
	bubble.global_position = fish_helper.global_position
	bubble.global_position.y = fish_helper.global_position.y - 6

func fisshe_animate():
	var facing_sign = -1 if sprite.flip_h else 1
	var duration = 0.15
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.set_parallel(true)
	
	tween.tween_property(fish_helper, "scale:x", facing_sign, duration)
	tween.tween_property(fish_helper, "position:x", -facing_sign * 42.0, duration)
