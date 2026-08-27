extends Area2D

var to_destroy = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		collected()
		to_destroy = true

func collected():
	Playerdata.shrooms =+ 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if to_destroy:
		queue_free()
