class_name ListItem
extends Control

signal remove_requested()

@onready var line_edit: LineEdit = %LineEdit

func _on_button_pressed() -> void:
	remove_requested.emit()

func _input(event: InputEvent) -> void:
	if event is not InputEventMouseButton:
		return

	var mouse_event: InputEventMouseButton = event

	if mouse_event.pressed and not line_edit.get_global_rect().has_point(mouse_event.position):
		line_edit.release_focus()
