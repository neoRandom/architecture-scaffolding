extends Control

@onready var item_container: VBoxContainer = %VBoxContainer

func _on_button_pressed() -> void:
	var item := LineEdit.new()

	item_container.add_child(item)
