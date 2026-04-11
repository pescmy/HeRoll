# floating_text.gd
extends Label

@export var float_speed: float = 50.0
@export var lifetime: float = 1.5

func _ready() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position", position + Vector2(0, -60), lifetime)
	tween.tween_property(self, "modulate:a", 0.0, lifetime)
	tween.tween_callback(queue_free).set_delay(lifetime)
