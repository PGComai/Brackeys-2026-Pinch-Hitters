extends Node2D
class_name MainScene


const NEW_LEVEL_1 = preload("uid://dpdin1o3kge0t")
const NEW_LEVEL_2 = preload("uid://ddjoiwjg48q85")
const NEW_LEVEL_3 = preload("uid://clu4b44ufdonv")
const NEW_LEVEL_4 = preload("uid://c4wc542g45kya")
const NEW_LEVEL_5 = preload("uid://c6jhqticy87b6")
const NEW_LEVEL_6 = preload("uid://0iv8w0fbfcc3")

const LEVELS: Array[PackedScene] = [
									NEW_LEVEL_1,
									NEW_LEVEL_2,
									NEW_LEVEL_3,
									NEW_LEVEL_4,
									NEW_LEVEL_5,
									NEW_LEVEL_6
									]


var current_level_idx: int = 0:
	set(value):
		current_level_idx = clampi(value, 0, LEVELS.size() - 1)
var current_level_scene: NewLevel
var level_transitioning_flag := false
var player_data: Dictionary


func _ready() -> void:
	load_level()
	user_unpause()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		if not level_transitioning_flag:
			if get_tree().paused:
				user_unpause()
			else:
				user_pause()


func user_pause() -> void:
	get_tree().paused = true
	%PauseMenu.activate()


func user_unpause() -> void:
	%PauseMenu.deactivate()
	get_tree().paused = false


func unload_current_level() -> void:
	current_level_scene.end_reached.disconnect(_on_current_level_end_reached)
	current_level_scene.toggle_interactable_input.disconnect(_on_level_toggle_interactable_input)
	current_level_scene.queue_free()
	_on_level_toggle_interactable_input(false)


func load_level() -> void:
	current_level_scene = LEVELS[current_level_idx].instantiate()
	add_child(current_level_scene)
	if player_data:
		current_level_scene.apply_player_data(player_data)
	current_level_scene.end_reached.connect(_on_current_level_end_reached)
	current_level_scene.toggle_interactable_input.connect(_on_level_toggle_interactable_input)


func _on_level_toggle_interactable_input(on: bool) -> void:
	%ControlHintAttack.toggle_alternate_text(on)


func increment_level_idx() -> bool:
	if current_level_idx == LEVELS.size() - 1:
		return false
	current_level_idx += 1
	return true


func handle_level_transition() -> void:
	level_transitioning_flag = true
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
	await tween.finished
	level_transitioning_flag = false


func _on_current_level_end_reached(data: Dictionary) -> void:
	player_data = data
	if increment_level_idx():
		handle_level_transition()


func _on_pause_menu_resume_requested() -> void:
	user_unpause()


func _on_pause_menu_reset_requested() -> void:
	user_unpause()
	handle_level_transition()


func _on_pause_menu_quit_requested() -> void:
	get_tree().quit()
