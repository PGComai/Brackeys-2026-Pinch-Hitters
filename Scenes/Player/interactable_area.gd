extends Area2D
class_name InteractableArea


func get_interactable() -> InteractableThing:
	print("getting interactable")
	if get_overlapping_areas():
		return get_overlapping_areas()[0]
	return null
