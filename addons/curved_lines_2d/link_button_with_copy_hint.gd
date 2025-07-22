@tool
extends LinkButton

class_name LinkButtonWithCopyHint

func _enter_tree() -> void:
	tooltip_text = "This link will open a webpage in your browser: " + uri
	tooltip_text += "\nRight click to copy this link"


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and not Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		DisplayServer.clipboard_set(uri)
		EditorInterface.get_editor_toaster().push_toast("Link copied!")
