extends Node2D
class_name LevelGenerator


const DEFAULT_ROOM_SIZE_TILES: Vector2i = Vector2i(20, 11)
const DEFAULT_ROOM_EMPTY_TILES: Vector2i = Vector2i(16, 7)
const GEN_TILESET = preload("uid://b0bpeg1j8o6y5")
const GEN_TILESET_16 = preload("uid://darw0lk61gky0")


var gen_seed: int = 0
var difficulty_factor: float = 1.0
var tilemap_layer := TileMapLayer.new()
var tilemap_layer_16 := TileMapLayer.new()
var level_rng := RandomNumberGenerator.new()


func _ready() -> void:
	level_rng.seed = hash(gen_seed)
	
	add_child(tilemap_layer)
	tilemap_layer.tile_set = GEN_TILESET
	add_child(tilemap_layer_16)
	tilemap_layer_16.tile_set = GEN_TILESET_16
