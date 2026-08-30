extends Area2D
class_name InteractableArea


func _ready() -> void:
	set_collision_layer_and_mask(7, 7)


func get_interactable() -> InteractableThing:
	if get_overlapping_areas():
		return get_overlapping_areas()[0]
	return null


func set_collision_layer_and_mask(layer: int, mask: int) -> void:
	for i: int in 16:
		set_collision_layer_value(i + 1, false)
		set_collision_mask_value(i + 1, false)
	set_collision_layer_value(layer, true)
	set_collision_mask_value(mask, true)
