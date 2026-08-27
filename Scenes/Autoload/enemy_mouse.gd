class_name Enemy
extends CharacterBody2D

enum State { PATROL, PROJECTILE, KNOCKED, BUBBLED }

@export var max_hp: int = 3
@export var patrol_speed: float = 40.0
@export var gravity: float = 400.0
@export var touch_damage: int = 1
@export var touch_knockback: float = 200.0
@export var touch_cooldown: float = 0.5

@export var bubble_duration: float = 3.0
@export var ledge_probe: float = 8.0  # how far ahead of center to check for ground

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox: Area2D = $Hurtbox

var hp: int
var state: State = State.PATROL
var direction: int = 1
var can_damage: bool = false
var touch_timer: float = 0.0
var bubble_timer: float = 0.0

func _ready() -> void:
	hp = max_hp
	add_to_group("hittable")
	motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
	hurtbox.body_entered.connect(_on_hurtbox_body_entered)

func _physics_process(delta: float) -> void:
	if touch_timer > 0.0:
		touch_timer -= delta

	match state:
		State.PATROL:
			velocity.y += gravity * delta
			velocity.x = direction * patrol_speed
			move_and_slide()
			if is_on_wall() or (is_on_floor() and not sees_ground_ahead()):
				direction *= -1
				sprite.flip_h = direction < 0
		State.PROJECTILE:
			move_projectile(delta)
		State.BUBBLED:
			process_bubbled(delta)

	if state != State.BUBBLED:
		check_hurtbox_overlaps()

func sees_ground_ahead() -> bool:
	var from := global_position + Vector2(ledge_probe * direction, 0)
	var query := PhysicsRayQueryParameters2D.create(from, from + Vector2(0, 32))
	query.exclude = [self]
	return not get_world_2d().direct_space_state.intersect_ray(query).is_empty()

func check_hurtbox_overlaps() -> void:
	for body in hurtbox.get_overlapping_bodies():
		if body is Player:
			try_damage_player(body)

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if state == State.BUBBLED:
		return
	if body is Player:
		try_damage_player(body)

func try_damage_player(player: Player) -> void:
	if touch_timer > 0.0:
		return
	if not player.has_method("hit"):
		return
	var away_from_player := (global_position - player.global_position).normalized()
	if away_from_player == Vector2.ZERO:
		away_from_player = Vector2.UP
	away_from_player = clean_normal(away_from_player)
	player.hit(touch_damage, -away_from_player * touch_knockback)
	velocity = away_from_player * touch_knockback
	touch_timer = touch_cooldown

func move_projectile(delta: float) -> void:
	var motion := velocity * delta
	var collision := move_and_collide(motion)
	if collision:
		var collider := collision.get_collider()
		var normal: Vector2 = clean_normal(collision.get_normal())
		if collider is Player:
			try_damage_player(collider)
			velocity = velocity.bounce(normal)
			return
		if can_damage and (collider is StaticBody2D or collider is TileMap or collider is TileMapLayer):
			#take_damage(1)
			velocity = velocity.bounce(normal)
			can_damage = false
		else:
			velocity = velocity.bounce(normal)

func clean_normal(normal: Vector2) -> Vector2:
	if abs(normal.x) > abs(normal.y):
		return Vector2(sign(normal.x), 0)
	else:
		return Vector2(0, sign(normal.y))

func hit(_damage: int, knockback: Vector2) -> void:
	take_damage(1)
	state = State.PROJECTILE
	motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
	velocity = knockback
	can_damage = true

func bubble() -> void:
	state = State.BUBBLED
	bubble_timer = bubble_duration
	velocity = Vector2.ZERO
	modulate = Color(1.0, 0.45, 0.85)

func process_bubbled(delta: float) -> void:
	bubble_timer -= delta
	if bubble_timer <= 0.0:
		modulate = Color(1, 1, 1)
		state = State.PATROL

func take_damage(amount: int) -> void:
	modulate.r += 0.5
	hp -= amount
	if hp <= 0:
		queue_free()
