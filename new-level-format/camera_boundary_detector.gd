extends Area2D
class_name CameraBoundaryDetector


@export var player: Player


var current_area: CameraBoundaryArea


func _on_area_entered(area: Area2D) -> void:
	var boundary_area: CameraBoundaryArea = area
	if player.camera_man:
		current_area = boundary_area
		apply_boundary_to_camera(player.camera_man, boundary_area)


func _on_area_exited(area: Area2D) -> void:
	if area != current_area:
		if get_overlapping_areas():
			var boundary_area: CameraBoundaryArea = get_overlapping_areas()[0]
			if player.camera_man and boundary_area != current_area:
				apply_boundary_to_camera(player.camera_man, boundary_area)


# will pause the game during transition
static func apply_boundary_to_camera(camera: CameraMan, boundary_area: CameraBoundaryArea, duration: float = 0.5) -> void:
	print("applying boundary to camera")
	var boundary_dict: Dictionary[String, int] = boundary_area.get_camera_bounds()
	if camera.initial_limit_set:
		camera.smooth_limit_transition_to(
			boundary_dict["left"],
			boundary_dict["top"],
			boundary_dict["right"],
			boundary_dict["bottom"],
			duration
		)
	else:
		camera.instant_limit_to(
			boundary_dict["left"],
			boundary_dict["top"],
			boundary_dict["right"],
			boundary_dict["bottom"],
		)
