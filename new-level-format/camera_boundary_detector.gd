extends Area2D
class_name CameraBoundaryDetector


@export var camera_to_affect: Camera2D


func _on_area_entered(area: Area2D) -> void:
	var boundary_area: CameraBoundaryArea = area
	if camera_to_affect:
		apply_boundary_to_camera(camera_to_affect, boundary_area)


static func apply_boundary_to_camera(camera: Camera2D, boundary_area: CameraBoundaryArea) -> void:
	var boundary_dict: Dictionary[String, int] = boundary_area.get_camera_bounds()
	camera.limit_left = boundary_dict["left"]
	camera.limit_top = boundary_dict["top"]
	camera.limit_right = boundary_dict["right"]
	camera.limit_bottom = boundary_dict["bottom"]
