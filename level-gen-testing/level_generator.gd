extends Node2D
class_name LevelGenerator


const DEFAULT_ROOM_SIZE_TILES: Vector2i = Vector2i(20, 11)
const DEFAULT_ROOM_EMPTY_TILES: Vector2i = Vector2i(16, 7)
const GEN_TILESET = preload("uid://b0bpeg1j8o6y5")


var gen_seed: int = 0
var difficulty_factor: float = 1.0



func _ready() -> void:
	pass
