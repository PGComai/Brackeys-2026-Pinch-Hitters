class_name Enemy
extends CharacterBody2D

const STUN_STARS = preload("uid://m32ggmldw4rb")
#const STAR_OFFSET_Y = -12
#const STAR_
const COLLIDER_SIZE: Vector2 = Vector2(60.0, 57.0)
const COLLIDER_OFFSET: Vector2 = Vector2(0.0, 1.5)
const COLLIDER_SIZE_HURTBOX: Vector2 = Vector2(56.0, 54.0)
const WALL_RAYCAST_TARGET_POS: Vector2 = Vector2(8.0, 0.0)
const DEBUG_COLOR_HURTBOX: Color = Color("f6007f6b")
const COLLISION_LAYER_VALUES: Array[int] = [2]
const COLLISION_MASK_VALUES: Array[int] = [3]
const COLLISION_LAYER_VALUES_HURTBOX: Array[int] = [2]
const COLLISION_MASK_VALUES_HURTBOX: Array[int] = [1]


enum EnemyStateEnum { PATROL, PROJECTILE, BUBBLED, STUNNED }

@export var max_hp: int = 3

@export var patrol_speed: float = 40.0
@export var gravity: float = 400.0
@export var touch_damage: int = 1
@export var touch_knockback: float = 200.0
@export var touch_cooldown: float = 0.5

@export var bubble_duration: float = 3.0
@export var ledge_probe: float = 8.0

@export_category("Nodes")
@export var sprite: AnimatedSprite2D
@export var wall_ray_cast: RayCast2D
@export var hurtbox: Area2D


var hp: int
var state: EnemyStateEnum = EnemyStateEnum.PATROL
var direction: int = 1
var can_damage: bool = false
var touch_timer: float = 0.0
var bubble_timer: float = 0.0
var stun_timer: float = 0.0
var stars: Node2D


func _ready() -> void:
	stars = STUN_STARS.instantiate()
	sprite.add_child(stars)
	stars.visible = false
	stars.position.y = -45
	stars.position.x = -12
	hp = max_hp
	add_to_group("hittable")
	motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
	hurtbox.body_entered.connect(_on_hurtbox_body_entered)


func clear_physics_layer_values(coll_obj: CollisionObject2D) -> void:
	for i: int in 16:
		coll_obj.set_collision_layer_value(i, false)


func clear_physics_mask_values(coll_obj: CollisionObject2D) -> void:
	for i: int in 16:
		coll_obj.set_collision_mask_value(i, false)


func _physics_process(delta: float) -> void:
	if touch_timer > 0.0:
		touch_timer -= delta

	match state:
		EnemyStateEnum.PATROL:
			velocity.y += gravity * delta
			velocity.x = direction * patrol_speed
			move_and_slide()
			if is_on_wall() or (is_on_floor() and not sees_ground_ahead()):
				direction *= -1
				sprite.scale.x *= -1
		EnemyStateEnum.PROJECTILE:
			move_projectile(delta)
		EnemyStateEnum.BUBBLED:
			process_bubbled(delta)
		EnemyStateEnum.STUNNED:
			stun_timer -= delta
			if stun_timer < 0:
				EnemyStateEnum.PATROL
				stars.visible = false

	if state != EnemyStateEnum.BUBBLED:
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
	if body is Player:
		if body.velocity.y > 0.01:
			stun()
			body.velocity.y = -abs(body.velocity.y) - 2
		else:
			try_damage_player(body)

func stun():
	state = EnemyStateEnum.STUNNED
	stun_timer = 5.0
	stars.visible = true

func try_damage_player(player: Player) -> void:
	if touch_timer > 0.0 or state == EnemyStateEnum.STUNNED:
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

func hit(damage: int, knockback: Vector2) -> void:
	take_damage(1)
	state = EnemyStateEnum.PROJECTILE
	motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
	velocity = knockback
	can_damage = true

func bubble() -> void:
	take_damage(1)

func process_bubbled(delta: float) -> void:
	bubble_timer -= delta
	if bubble_timer <= 0.0:
		modulate = Color.WHITE
		state = EnemyStateEnum.PATROL

func take_damage(amount: int) -> void:
	modulate.r += 0.5
	hp -= amount
	if hp <= 0:
		queue_free()
