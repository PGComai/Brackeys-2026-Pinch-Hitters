extends Area2D

var direction = 1
var speed = 200.0

var destroyed = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _physics_process(delta: float) -> void:
	if destroyed:
		return
	position.x += speed * direction * delta


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("bubble"):
		body.bubble()
		animation_player.play("new_animation_2")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "new_animation_2":
		if destroyed == true:
			queue_free()
