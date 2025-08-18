extends Node

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_IN:
		Engine.time_scale = 1.0
		OS.low_processor_usage_mode = false
		get_tree().paused = false
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		Engine.time_scale = 0.0
		OS.low_processor_usage_mode = true
		get_tree().paused = true
