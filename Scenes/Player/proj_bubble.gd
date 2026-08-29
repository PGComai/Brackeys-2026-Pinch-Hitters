extends Area2D

var direction = 1
var speed = 200.0

var destroyed = false
@export var lifetime = 20.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var pop_sound: AudioStream

func _physics_process(delta: float) -> void:
	if destroyed:
		return
	position.x += speed * direction * delta
	lifetime -= delta
	if lifetime <= 0:
		pop()


func pop() -> void:
	destroyed = true
	animation_player.play("new_animation_2")
	if pop_sound:
		var asp := AudioStreamPlayer.new()
		asp.stream = pop_sound
		asp.bus = &"SFX"
		asp.autoplay = true
		add_sibling(asp)
		asp.finished.connect(asp.queue_free)


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("bubble") and not destroyed:
		body.bubble()
		pop()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "new_animation_2":
		if destroyed == true:
			queue_free()
