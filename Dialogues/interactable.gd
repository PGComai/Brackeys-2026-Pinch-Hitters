extends Area2D

@export var dialogue_resource: DialogueResource
#@export var dialogue_sound: AudioStream = preload("res://Assets/Sounds/beep_generic.ogg")

@onready var player: CharacterBody2D

@export var killkillkill = false
@export var automatic = false

var start_node: String = "start"
var end_node: String = "END"

var dialogue_lock := false
var player_nearby := false

func _ready() -> void:
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func _process(delta: float) -> void:
	if automatic and interactable():
		interact()

func _input(event: InputEvent) -> void:
	if !automatic:
		if player_nearby and event.is_action_pressed("Down") and interactable():
			interact()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body
		player_nearby = true
		print("PLAYER NEARBY")

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_nearby = false

func _on_dialogue_started(res: DialogueResource) -> void:
	if res == dialogue_resource:
		#player.velocity = Vector2.ZERO
		dialogue_lock = true
		get_tree().paused = true

func _on_dialogue_ended(res: DialogueResource) -> void:
	if res == dialogue_resource:
		await get_tree().create_timer(0.1, true).timeout
		get_tree().paused = false
		dialogue_lock = false
		if killkillkill:
			queue_free()

func set_player_nearby(value: bool) -> void:
	player_nearby = value
	print("PLAYER NEARBY")

func interactable() -> bool:
	return dialogue_resource != null and !dialogue_lock

func interact() -> void:
	var balloon = DialogueManager.show_dialogue_balloon(dialogue_resource, start_node)

	if balloon == null:
		return

	if !balloon.is_node_ready():
		await balloon.ready

	#if balloon.has_node("DialogueSound"):
		#balloon.get_node("DialogueSound").stream = dialogue_sound
	#elif balloon.has_method("set_dialogue_sound"):
		#balloon.set_dialogue_sound(dialogue_sound)
	#elif "dialogue_sound" in balloon:
		#balloon.dialogue_sound.stream = dialogue_sound
