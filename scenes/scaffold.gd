class_name Scaffold
extends PanelContainer

@onready var saved_label: Label = %SavedLabel
@onready var exported_label: Label = %ExportedLabel
@onready var delete_confirmation_pop_up_container: CenterContainer = %DeleteConfirmationPopUpContainer

const APP_FILE_DIALOG := preload("uid://msbu8a15d1gm")

func _ready() -> void:
	delete_confirmation_pop_up_container.visible = false
	saved_label.visible = false
	exported_label.visible = false

	DataStore.data_saved.connect(
		func() -> void:
			saved_label.visible = true
			await get_tree().create_timer(1).timeout
			saved_label.visible = false
	)
	DataStore.data_exported.connect(
		func() -> void:
			exported_label.visible = true
			await get_tree().create_timer(1).timeout
			exported_label.visible = false
	)

func _on_save_button_pressed() -> void:
	DataStore.save_data()

func _on_delete_save_button_pressed() -> void:
	delete_confirmation_pop_up_container.visible = true

func _on_previous_button_pressed() -> void:
	Command.next_step_required.emit(true)

func _on_next_button_pressed() -> void:
	Command.next_step_required.emit(false)


func _on_confirm_delete_button_pressed() -> void:
	DataStore.delete_save()
	delete_confirmation_pop_up_container.visible = false


func _on_cancel_delete_button_pressed() -> void:
	delete_confirmation_pop_up_container.visible = false


func _on_import_button_pressed() -> void:
	var file_dialog: FileDialog = APP_FILE_DIALOG.instantiate()
	get_tree().current_scene.add_child(file_dialog)

	file_dialog.file_selected.connect(
		func(path: String) -> void:
			DataStore.load_save(path)
			file_dialog.queue_free()
	)


func _on_export_button_pressed() -> void:
	var file_dialog: FileDialog = APP_FILE_DIALOG.instantiate()
	get_tree().current_scene.add_child(file_dialog)
	file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE

	file_dialog.file_selected.connect(
		func(path: String) -> void:
			DataStore.export_save(path)
			file_dialog.queue_free()
	)
