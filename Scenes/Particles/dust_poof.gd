extends CPUParticles2D

func _ready() -> void:
	emitting = true
	finished.connect(queue_free) # delete self after one-shot particles finished