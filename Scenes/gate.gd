extends InteractableThing
class_name Gate


var is_open := false
var is_entered := false


func do_interaction() -> InteractableThing.InteractableType:
	if not is_open:
		open()
		return InteractableType.GATE
	elif not is_entered:
		is_entered = true
		return InteractableType.GATE_OPEN
	return InteractableType.NONE


func open() -> void:
	is_open = true
	%AnimatedSprite2D.play("default")
	await %AnimatedSprite2D.animation_finished
	#%CollisionShape2D.disabled = true


func close() -> void:
	is_open = false
	%AnimatedSprite2D.play_backwards("default")
	await %AnimatedSprite2D.animation_finished
	#%CollisionShape2D.disabled = false


func open_instantly() -> void:
	is_open = true
	%AnimatedSprite2D.set_frame_and_progress(%AnimatedSprite2D.sprite_frames.get_frame_count("default"), 1.0)
	#%CollisionShape2D.disabled = true


func close_instantly() -> void:
	is_open = false
	%AnimatedSprite2D.set_frame_and_progress(0, 0.0)
	#%CollisionShape2D.disabled = false
