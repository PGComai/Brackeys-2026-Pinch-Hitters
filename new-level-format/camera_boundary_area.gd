@tool
extends HandyArea
class_name CameraBoundaryArea


const DEFAULT_RECT_SIZE := Vector2(640.0, 352.0)
const PHYSICS_LAYER: int = 6
const PHYSICS_MASK: int = 6


func _ready() -> void:
	set_collision_layer_and_mask(PHYSICS_LAYER, PHYSICS_MASK)


func get_camera_bounds() -> Dictionary[String, int]:
	return {
		"left": roundi(global_position.x) - roundi(rect_shape.size.x / 2.0),
		"top": roundi(global_position.y) - roundi(rect_shape.size.y / 2.0),
		"right": roundi(global_position.x) + roundi(rect_shape.size.x / 2.0),
		"bottom": roundi(global_position.y) + roundi(rect_shape.size.y / 2.0)
	}
