class_name Scaffold
extends PanelContainer

func _on_save_button_pressed() -> void:
	DataStore.save_data()

func _on_delete_save_button_pressed() -> void:
	DataStore.delete_save()

func _on_previous_button_pressed() -> void:
	Command.next_step_required.emit(true)

func _on_next_button_pressed() -> void:
	Command.next_step_required.emit(false)
