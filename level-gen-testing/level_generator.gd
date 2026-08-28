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


#func build() -> void:
	#clear()
	#var terrain_zone: Array[Vector2i] = []
	#for x: int in map_size.x:
		#for y: int in map_size.y:
			#var nval: float = map_noise.get_noise_2d(x, y)
			#if nval > map_noise_threshold:
				#set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
				#terrain_zone.append(Vector2i(x, y))
			#else:
				#set_cell(Vector2i(x, y), 0, Vector2i(0, 4))
	#set_cells_terrain_connect(terrain_zone, 0, 0, false)
	#camera_2d.position = gps(map_size / 2)
	#cam_pos_target = camera_2d.position
