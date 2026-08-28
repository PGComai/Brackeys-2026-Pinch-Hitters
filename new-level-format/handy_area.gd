@tool
extends Area2D
class_name HandyArea


@export var size_override := Vector2.ZERO:
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


func set_collision_layer_and_mask(layer: int, mask: int) -> void:
	for i: int in 16:
		set_collision_layer_value(i + 1, false)
		set_collision_mask_value(i + 1, false)
	set_collision_layer_value(layer, true)
	set_collision_mask_value(mask, true)


func _enter_tree() -> void:
	if get_child_count():
		for child in get_children():
			child.queue_free()
		# when duplicating in gui
		collision_shape = CollisionShape2D.new()
		rect_shape = RectangleShape2D.new()
	add_child(collision_shape)
	rect_shape.size = size_override
	collision_shape.shape = rect_shape
