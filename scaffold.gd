class_name Scaffold
extends PanelContainer

@onready var saved_label: Label = %SavedLabel
@onready var delete_confirmation_pop_up_container: CenterContainer = %DeleteConfirmationPopUpContainer

func _ready() -> void:
	delete_confirmation_pop_up_container.visible = false
	saved_label.visible = false

	DataStore.data_saved.connect(
		func() -> void:
			saved_label.visible = true
			await get_tree().create_timer(1).timeout
			saved_label.visible = false
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
