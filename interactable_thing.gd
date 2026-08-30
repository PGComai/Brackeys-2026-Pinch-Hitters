extends Area2D
class_name InteractableThing


enum InteractableType{CHEST}


var interactable_type: InteractableType
var treasure: Variant
var done := false


func _enter_tree() -> void:
	set_collision_layer_and_mask(7, 7)


func set_collision_layer_and_mask(layer: int, mask: int) -> void:
	for i: int in 16:
		set_collision_layer_value(i + 1, false)
		set_collision_mask_value(i + 1, false)
	set_collision_layer_value(layer, true)
	set_collision_mask_value(mask, true)
