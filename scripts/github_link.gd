extends RichTextLabel

func _ready() -> void:
	if OS.get_name() != "HTML5":
		self.connect("meta_clicked", self._on_meta_clicked)

func _on_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))
