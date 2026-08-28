@tool
extends Area2D
class_name CameraBoundaryArea


const DEFAULT_RECT_SIZE := Vector2(640.0, 352.0)
const PHYSICS_LAYER: int = 6
const PHYSICS_MASK: int = 6


@export var size_override := DEFAULT_RECT_SIZE:
	set(value):
		if size_override != value:
			size_override = value
			handle_size_override()


var collision_shape := CollisionShape2D.new()
var rect_shape := RectangleShape2D.new()


# when changing size in code
func set_size_override_value(override: Vector2) -> void:
	rect_shape.size = override


# when changing size in gui
func handle_size_override() -> void:
	if Engine.is_editor_hint():
		set_size_override_value(size_override)


func _enter_tree() -> void:
	for i: int in 16:
		set_collision_layer_value(i + 1, false)
		set_collision_mask_value(i + 1, false)
	set_collision_layer_value(6, true)
	set_collision_mask_value(6, true)
	if get_child_count():
		for child in get_children():
			child.queue_free()
		# when duplicating in gui
		collision_shape = CollisionShape2D.new()
		rect_shape = RectangleShape2D.new()
	add_child(collision_shape)
	rect_shape.size = size_override
	collision_shape.shape = rect_shape


func get_camera_bounds() -> Dictionary[String, int]:
	return {
		"left": roundi(global_position.x) - roundi(rect_shape.size.x / 2.0),
		"top": roundi(global_position.y) - roundi(rect_shape.size.y / 2.0),
		"right": roundi(global_position.x) + roundi(rect_shape.size.x / 2.0),
		"bottom": roundi(global_position.y) + roundi(rect_shape.size.y / 2.0)
	}
