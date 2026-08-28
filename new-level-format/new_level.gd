extends Node2D
class_name NewLevel


const PLAYER = preload("uid://buvdkp3gc6t3a")
const DEFAULT_PLAYER_SPAWN := Vector2(104.0, 256.0)


@export var player_spawn: Marker2D


var player: Player


func _ready() -> void:
	spawn_player()


func spawn_player() -> void:
	player = PLAYER.instantiate()
	add_child(player)
	if player_spawn:
		player.global_position = player_spawn.global_position
	else:
		player.global_position = DEFAULT_PLAYER_SPAWN
