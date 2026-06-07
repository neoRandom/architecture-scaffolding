extends Node


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		Command.window_mode_request.emit(
			DisplayServer.WINDOW_MODE_WINDOWED
			if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
			else DisplayServer.WINDOW_MODE_FULLSCREEN
		)
