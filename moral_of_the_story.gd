extends RichTextLabel
class_name MoralOfTheStory


signal text_paused


const SENTENCES: Array[int] = [139, 252, 338]


var active := false
var paused := false
var sentences_read: int = 0
var frame_counter: int = 0


func _ready() -> void:
	visible_characters = 0


func reveal_character() -> void:
	visible_characters += 1
	%AudioStreamPlayerCharacter.play()
	%AudioStreamPlayerCharacter.pitch_scale = randfn(2.0, 0.02)
	if visible_characters == SENTENCES[sentences_read]:
		paused = true
		sentences_read += 1
		text_paused.emit()


func _process(delta: float) -> void:
	if active and not paused:
		if frame_counter % 3 == 0:
			reveal_character()
		frame_counter += 1


func is_done() -> bool:
	return sentences_read == SENTENCES.size()
