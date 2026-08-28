extends Camera2D
class_name CameraMan


signal smooth_transition_finished


var desired_limits: Array[int] = [0, 0, 640, 352]
var initial_limit_set := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func instant_limit_to(left: int, top: int, right: int, bottom: int) -> void:
	limit_left = left
	limit_top = top
	limit_right = right
	limit_bottom = bottom
	initial_limit_set = true


func _set_limit(limits: Array[int]) -> void:
	limit_left = limits[0]
	limit_top = limits[1]
	limit_right = limits[2]
	limit_bottom = limits[3]


func ease_limits(value: float) -> void:
	limit_left = lerp(limit_left, desired_limits[0], value)
	limit_top = lerp(limit_top, desired_limits[1], value)
	limit_right = lerp(limit_right, desired_limits[2], value)
	limit_bottom = lerp(limit_bottom, desired_limits[3], value)


# cursed and bad
func smooth_limit_transition_to(left: int, top: int, right: int, bottom: int, time: float = 0.5, pause := true):
	
	if pause:
		get_tree().paused = true
	
	desired_limits = [left, top, right, bottom]
	
	var tween := get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	tween.tween_method(ease_limits, 0.0, 1.0, 0.5).set_trans(Tween.TRANS_CUBIC)
	
	#var tween := get_tree().create_tween()
	#
	#tween.tween_method(
		#_set_limit,
		#[limit_left, limit_top, limit_right, limit_bottom],
		#[left, top, right, bottom],
		#time
	#)
	
	#if left != limit_left or right != limit_right:
		#if left < limit_left:
			#print("cam trans left")
			#tween.tween_property(self, "limit_left", left, time * 0.9).set_trans(Tween.TRANS_CUBIC)
			#tween.tween_property(self, "limit_right", right, time).set_trans(Tween.TRANS_CUBIC)
		#else:
			#print("cam trans right")
			#tween.tween_property(self, "limit_right", right, time * 0.9).set_trans(Tween.TRANS_CUBIC)
			#tween.tween_property(self, "limit_left", left, time).set_trans(Tween.TRANS_CUBIC)
	#
	#if top != limit_top or bottom != limit_bottom:
		#if top < limit_top:
			#print("cam trans up")
			#tween.tween_property(self, "limit_top", top, time * 0.9).set_trans(Tween.TRANS_CUBIC)
			#tween.tween_property(self, "limit_bottom", bottom, time).set_trans(Tween.TRANS_CUBIC)
		#else:
			#print("cam trans down")
			#tween.tween_property(self, "limit_bottom", bottom, time * 0.9).set_trans(Tween.TRANS_CUBIC)
			#tween.tween_property(self, "limit_top", top, time).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	print("boundary tween finished")
	if pause:
		get_tree().paused = false
	
	smooth_transition_finished.emit()
