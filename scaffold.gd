class_name Scaffold
extends PanelContainer

func _on_save_button_pressed() -> void:
	DataStore.save_data()


func _on_delete_save_button_pressed() -> void:
	DataStore.delete_save()
