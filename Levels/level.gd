extends Node2D

@export var level_title: String = "???"
@export_file("*.tscn") var next_level: String

@export var start_with_transition: bool = true
@export var end_with_transition: bool = true
@export var ui_visible: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
