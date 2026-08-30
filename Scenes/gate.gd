extends AnimatedSprite2D
class_name Gate


func open() -> void:
	play("default")
	await animation_finished
	%CollisionShape2D.disabled = true


func close() -> void:
	play_backwards("default")
	await animation_finished
	%CollisionShape2D.disabled = false


func open_instantly() -> void:
	set_frame_and_progress(sprite_frames.get_frame_count("default"), 1.0)
	%CollisionShape2D.disabled = true


func close_instantly() -> void:
	set_frame_and_progress(0, 0.0)
	%CollisionShape2D.disabled = false
