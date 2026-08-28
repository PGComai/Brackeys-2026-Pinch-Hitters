extends Node2D
class_name MainScene


const NEW_LEVEL_1 = preload("uid://dpdin1o3kge0t")
const LEVELS: Array[PackedScene] = [NEW_LEVEL_1, ]


var current_level_idx: int = 0:
	set(value):
		current_level_idx = clampi(value, 0, LEVELS.size() - 1)
var current_level_scene: NewLevel


func _ready() -> void:
	load_level()


func unload_current_level() -> void:
	current_level_scene.queue_free()


func load_level() -> void:
	#if this throws errors after unload_current_level, maybe uncomment this
	#await get_tree().process_frame
	var level_to_load: NewLevel = LEVELS[current_level_idx].instantiate()
	add_child(level_to_load)


func increment_level_idx() -> bool:
	if current_level_idx == LEVELS.size() - 1:
		return false
	current_level_idx += 1
	return true


func _on_current_level_end_reached() -> void:
	if increment_level_idx():
		unload_current_level()
		load_level()
