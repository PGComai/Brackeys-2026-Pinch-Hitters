extends Node2D

@export var level_title: String = "???"
@export_file("*.tscn") var next_level: String

@export var start_with_transition: bool = true
@export var end_with_transition: bool = true
@export var ui_visible: bool = true

@onready var transition_player: AnimationPlayer = $UserInterface/TransitionPlayer

func _ready() -> void:
	if start_with_transition:
		transition_player.play("new_animation")
		get_tree().paused = true

func _on_transition_player_animation_finished(anim_name: StringName) -> void:
	if start_with_transition:
		if anim_name == "new_animation":
			get_tree().paused = false
