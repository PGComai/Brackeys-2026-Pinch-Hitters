class_name Player
extends CharacterBody2D

@export var gravity: float = 500.0
@export var inverted = false

@export var on_the_space_level = false

var hp = 5

@export var speed: float = 250.0
@export var acceleration: float = 800.0
@export var friction: float = 1200.0
@export var air_friction: float = 80.0
@export var climb_speed: float = 100.0
const JUMP_VELOCITY = -300
const JUMP_CUT = 2.5
const SHOOT_COOLDOWN = 0.5

# TODO: Replace with globals or inventory?
@export var has_hammer: bool = true
@export var hammer_damage = 1
@export var hammer_knockback = 300.0
@export var has_fish: bool = true

@export var invincibility_duration: float = 1.2
@export var blink_interval: float = 0.08

@export var hitstop_duration: float = 0.1
@export var hitstop_scale: float = 0.05

const NO_AIM = -999.0

@onready var visual: Node2D = $Visual
@onready var sprite: AnimatedSprite2D = $Visual/Sprite
@onready var fish: Node2D = $Fish
@onready var fish_sprite: AnimatedSprite2D = $Fish/Sprite
@onready var bubble_sfx: AudioStreamPlayer = $Fish/BubbleSFX

@onready var anim_player: AnimationPlayer = $Visual/AnimationPlayer

const LANDPARTICLES = preload("res://Scenes/Player/land_particles.tscn")
const PROJBUBBLE = preload("res://Scenes/Player/proj_bubble.tscn")

var was_on_floor = true

@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_buffer_timer: Timer = $JumpBufferTimer

@onready var hammer_time: Node2D = $HammerTime
@onready var hammer_hitbox: Area2D = $HammerTime/HammerHitbox

@onready var climb_hitbox: Area2D = $ClimbArea

@onready var state_machine: StateMachine = $StateMachine

@onready var dust_trail: CPUParticles2D = $Visual/DustTrail

var frames := 0

@onready var spawn_point: Vector2 = global_position

@onready var user_interface: CanvasLayer = $"../UserInterface"

var is_invincible: bool = false
var invincibility_timer: float = 0.0
var blink_timer: float = 0.0
var blink_tween: Tween
var hitstop_active: bool = false
var shoot_timer = 0.0

var camera_man: CameraMan

func _ready() -> void:
	was_on_floor = is_on_floor()
	

func _physics_process(delta: float) -> void:
	if not state_machine.in_state("Climb"):
		velocity.y += delta * gravity
	#if Input.is_action_pressed("Jump"):
	#	velocity.y = JUMP_VELOCITY
	#jump()
	dust_trail.emitting = is_on_floor() and abs(velocity.x) > (speed / 2.0)
	move_and_slide()


func _process(delta: float) -> void:
	camera_man.position = global_position
	update_hammer_rotation()
	visual_update()
	shoot_timer -= delta


func _input(_event: InputEvent) -> void:
	if has_fish:
		if Input.is_action_pressed("Bubble") and shoot_timer <= 0.0:
			shoot_timer = SHOOT_COOLDOWN
			fisshe_bubble(-1 if visual.scale.x < 0 else 1)
	#if Input.is_action_just_pressed("Restart"):
	#	get_tree().reload_current_scene()
	if not has_hammer:
		return
	#if Input.is_action_just_pressed("Fire"):
   	#	hammer_hit()


func ground_movement(delta: float, dir: float) -> void:
	if not is_zero_approx(dir):
		set_facing(dir < 0)
		velocity.x += dir * acceleration * delta
		velocity.x = clamp(velocity.x, -speed, speed)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)


func air_movement(delta: float, dir: float) -> void:
	if not is_zero_approx(dir):
		set_facing(dir < 0)
		velocity.x += dir * acceleration * delta
		velocity.x = clamp(velocity.x, -speed, speed)
	else:
		velocity.x = move_toward(velocity.x, 0, air_friction * delta)


func climb_check() -> bool:
	if can_climb() and Input.is_action_pressed("Up"):
		state_machine.change_state("Climb")
		return true
	return false


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


#func jump():
	#if not on_the_space_level:
	#	if Input.is_action_just_pressed("Jump"):
	#		jump_buffer_timer.start()
	#if is_on_floor():
	#	coyote_timer.start()
	#if jump_buffer_timer.time_left > 0:
	#if Input.is_action_just_pressed("Jump") and is_on_floor(): #  and coyote_timer.time_left > 0:
			#velocity.y = JUMP_VELOCITY
			#jump_buffer_timer.stop()
	#		coyote_timer.stop()
	#		jump_sound.play()


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


func hit(damage: int, knockback: Vector2) -> void:
	if is_invincible:
		return
	hp = max(hp - damage, 0)
	if hp:
		start_invincibility()
	else:
		die()

	var push_dir := signf(knockback.x) if knockback.x != 0 else (-1.0 if sprite.flip_h else 1.0)
	velocity.x = push_dir * abs(hammer_knockback)
	#hurt_sound.play()


func start_invincibility() -> void:
	invincibility_timer = invincibility_duration
	is_invincible = true

	if blink_tween:
		blink_tween.kill()

	blink_tween = create_tween()
	blink_tween.set_loops()
	blink_tween.tween_property(sprite, "self_modulate", Color.DIM_GRAY, blink_interval)
	blink_tween.tween_property(sprite, "self_modulate", Color.WHITE, blink_interval)


func update_invincibility(delta: float) -> void:
	if invincibility_timer <= 0.0:
		return

	invincibility_timer = max(invincibility_timer - delta, 0.0)

	if invincibility_timer <= 0.0:
		is_invincible = false
		if blink_tween:
			blink_tween.kill()
		sprite.self_modulate = Color.WHITE

func die() -> void:
	get_tree().reload_current_scene()

	#hurt_sound.play()
	#anim_player.play("RESET")
	#death_animation.play("death")
	#game_over.play()
	#
	#modulate = Color.DIM_GRAY
	#
	#get_tree().current_scene.pausable = false
	#get_tree().paused = true

func _on_death_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		if spawn_point != Vector2.INF:
			anim_player.play("RESET")

			get_tree().current_scene.pausable = true
			get_tree().paused = false

			modulate = Color.WHITE

			position = spawn_point
			inverted = false
			velocity = Vector2(0, 0)
		else:
			get_tree().paused = false
			get_tree().reload_current_scene()


func fisshe_bubble(direction):
	var bubble := PROJBUBBLE.instantiate() as Node2D
	bubble.direction = direction
	add_sibling(bubble)
	bubble.z_index = z_index + 1
	bubble.global_position = fish.global_position
	bubble.global_position.y = fish.global_position.y - 6
	fish_sprite.play("fire")
	bubble_sfx.play()


func visual_update():
	fish.visible = has_fish
	if has_fish:
		var facing_sign = visual.scale.x
		var duration = 0.05
		
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.set_parallel(true)
		
		tween.tween_property(fish, "scale:x", facing_sign, duration)
		tween.tween_property(fish, "position:x", -facing_sign * 42.0, duration)


func set_facing(left: bool) -> void:
	visual.scale.x = -1 if left else 1


func get_anim_name(anim_name: StringName) -> StringName:
	if has_hammer:
		anim_name = "hammer/" + anim_name
	return anim_name 


func play_animation(anim_name: StringName) -> void:
	# TODO: Animation player should change AnimatedSprite2D's animation.
	anim_player.play(get_anim_name(anim_name))


func queue_animation(anim_name: StringName) -> void:
	anim_player.queue(get_anim_name(anim_name))


func get_current_anim() -> StringName:
	return anim_player.assigned_animation


func get_movement_axis() -> float:
	return Input.get_axis(&"Left", &"Right")


func get_movement_vector() -> Vector2:
	return Input.get_vector(&"Left", &"Right", &"Up", &"Down")


func is_jump_pressed() -> bool:
	return Input.is_action_just_pressed(&"Jump")


func try_bounce() -> bool:
	if velocity.y > 0.01:
		velocity.y = -abs(velocity.y) - 2
		if is_jump_pressed():
			velocity.y += JUMP_VELOCITY / 2.0
		state_machine.change_state("Jump")
		return true
	return false


func can_climb() -> bool:
	return climb_hitbox.has_overlapping_bodies()
