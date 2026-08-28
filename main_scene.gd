extends Node2D
class_name MainScene


const NEW_LEVEL_1 = preload("uid://dpdin1o3kge0t")
const NEW_LEVEL_2 = preload("uid://ddjoiwjg48q85")
const LEVELS: Array[PackedScene] = [
									NEW_LEVEL_1,
									NEW_LEVEL_2,
									]


var current_level_idx: int = 0:
	set(value):
		current_level_idx = clampi(value, 0, LEVELS.size() - 1)
var current_level_scene: NewLevel


func _ready() -> void:
	load_level()


func unload_current_level() -> void:
	current_level_scene.end_reached.disconnect(_on_current_level_end_reached)
	current_level_scene.queue_free()


func load_level() -> void:
	current_level_scene = LEVELS[current_level_idx].instantiate()
	add_child(current_level_scene)
	current_level_scene.end_reached.connect(_on_current_level_end_reached)


func increment_level_idx() -> bool:
	if current_level_idx == LEVELS.size() - 1:
		return false
	current_level_idx += 1
	return true


func handle_level_transition() -> void:
	await get_tree().process_frame
	var tween := get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	get_tree().paused = true
	
	tween.tween_property(%ColorRectTransition, "instance_shader_parameters/progress", 1.0, 0.5).set_trans(Tween.TRANS_CUBIC)
	
	await tween.finished
	
	unload_current_level()
	print("transition unloaded level")
	
	load_level()
	print("transition loaded level")
	
	get_tree().paused = false
	tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	tween.tween_property(%ColorRectTransition, "instance_shader_parameters/progress", 0.0, 0.5).set_trans(Tween.TRANS_CUBIC)
	


func _on_current_level_end_reached() -> void:
	if increment_level_idx():
		handle_level_transition()
