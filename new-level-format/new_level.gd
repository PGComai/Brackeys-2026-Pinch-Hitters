extends Node2D
class_name NewLevel


signal end_reached


const PLAYER = preload("uid://buvdkp3gc6t3a")
const DEFAULT_PLAYER_SPAWN := Vector2(104.0, 256.0)


@export var player_spawn: Marker2D
@export var level_end: LevelEnd


var player: Player
var camera_man := CameraMan.new()
var already_ended := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	spawn_player()
	if level_end:
		level_end.end_reached.connect(_on_level_end_end_reached)


func spawn_player() -> void:
	player = PLAYER.instantiate()
	add_child(player)
	if player_spawn:
		player.global_position = player_spawn.global_position
	else:
		player.global_position = DEFAULT_PLAYER_SPAWN
	add_child(camera_man)
	player.camera_man = camera_man


func _on_level_end_end_reached() -> void:
	if not already_ended:
		end_reached.emit()
		already_ended = true
