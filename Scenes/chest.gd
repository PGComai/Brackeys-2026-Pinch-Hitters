extends Area2D

enum Type {HATE, LOVE}
@export var chest_type = Type.HATE

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactable_type = InteractableType.CHEST
	if chest_type == Type.HATE:
		animated_sprite_2d.play("dont")
	if chest_type == Type.LOVE:
		animated_sprite_2d.play("love")
