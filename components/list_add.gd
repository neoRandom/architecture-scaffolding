class_name ListAdd
extends Control

@onready var item_container: VBoxContainer = %VBoxContainer

const LIST_ITEM = preload("uid://dby4oqte32byo")


func _on_button_pressed() -> void:
	add_new_item()


func get_all() -> Array[String]:
	var all_items: Array[String] = []

	for item: ListItem in item_container.get_children():
		all_items.append(item.line_edit.text)

	return all_items

func add_new_item(text: String = "") -> void:
	var item: ListItem = LIST_ITEM.instantiate()

	item_container.add_child(item)
	item.remove_requested.connect(func(): item.queue_free())

	item.line_edit.text = text
