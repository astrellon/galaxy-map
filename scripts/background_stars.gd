extends Sprite2D

@export var time_offset: float = 4.0

func _process(_delta: float) -> void:
	var time = Time.get_ticks_msec() / 1000.0
	if time > time_offset:
		pass
