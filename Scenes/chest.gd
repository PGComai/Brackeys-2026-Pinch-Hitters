extends InteractableThing

enum Type {FISH, HATE, LOVE}


const ANIMS: Dictionary[Type, StringName] = {
	Type.FISH: &"fish",
	Type.HATE: &"hate",
	Type.LOVE: &"love"
}


@export var chest_type = Type.FISH


var opened := false


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func do_interaction() -> InteractableThing.InteractableType:
	if not opened:
		open_chest()
		return InteractableType.CHEST
	return InteractableType.NONE


func is_interactable() -> bool:
	return not opened


func open_chest() -> void:
	opened = true
	animated_sprite_2d.play(ANIMS[chest_type])


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animated_sprite_2d.animation = ANIMS[chest_type]
	animated_sprite_2d.set_frame_and_progress(0, 0.0)
