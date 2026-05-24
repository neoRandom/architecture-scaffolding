extends Node


func _ready() -> void:
	Command.window_mode_request.connect(handle_window_mode_request)

func handle_window_mode_request(mode: DisplayServer.WindowMode) -> void:
	var window_mode := DisplayServer.WINDOW_MODE_FULLSCREEN

	if DisplayServer.window_get_mode() == window_mode:
		window_mode = DisplayServer.WINDOW_MODE_WINDOWED

	DisplayServer.window_set_mode(mode)
