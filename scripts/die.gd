class_name Die
extends AnimatedSprite2D

signal roll_finished(result: int)

@export var sides: int = 6
@export var flicker_count: int = 10
@export var flicker_delay: float = 0.05  # seconds between flickers

var rolling: bool = false
var flickers_done: int = 0
var final_result: int = 1

# Public function: start rolling the die
func roll_die(duration: float = 1.5) -> void:
	if rolling:
		return
	rolling = true
	flickers_done = 0
	final_result = randi_range(1, sides)
	animate_roll(duration)

# Handles only the flicker animation
func animate_roll(duration: float) -> void:
	var timer := Timer.new()
	timer.wait_time = duration / flicker_count
	timer.one_shot = false
	add_child(timer)

	timer.timeout.connect(func() -> void:
		flickers_done += 1
		frame = randi_range(0, sides - 1)

		if flickers_done >= flicker_count:
			timer.stop()
			timer.queue_free()
			show_final_result()
	)
	timer.start()

# Sets the final die result and emits the signal
func show_final_result() -> void:
	frame = final_result - 1
	emit_signal("roll_finished", final_result)
	rolling = false
