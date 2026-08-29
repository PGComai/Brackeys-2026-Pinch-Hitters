@tool
extends HandyArea
class_name LevelEnd


signal end_reached


const PHYSICS_LAYER: int = 1
const PHYSICS_MASK: int = 1


func _ready() -> void:
	set_collision_layer_and_mask(PHYSICS_LAYER, PHYSICS_MASK)
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		end_reached.emit()
