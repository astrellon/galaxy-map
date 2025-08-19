extends Control

@export var raymarch_scene: LineEdit

func _ready() -> void:
	self.raymarch_scene.text_submitted.connect(self._on_raymarch_scene_submitted)

func _on_raymarch_scene_submitted(new_text: String) -> void:
	if new_text.is_valid_int():
		var scene = int(new_text)
		CelestialParent.instance.current_scene.raymarch_node.set_parameter('uScene', scene)
