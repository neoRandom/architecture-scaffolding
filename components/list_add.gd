class_name ListAdd
extends Control

signal item_added(uid: int)
signal item_removed(uid: int)
signal item_text_changed(uid: int, new_text: String)

@onready var item_container: VBoxContainer = %VBoxContainer

const LIST_ITEM = preload("uid://dby4oqte32byo")


func _on_button_pressed() -> void:
	add_new_item()

func get_all() -> Array[String]:
	var all_items: Array[String] = []

	for item: ListItem in item_container.get_children():
		all_items.append(item.line_edit.text)

	return all_items

func add_new_item(text: String = "") -> int:
	var item: ListItem = LIST_ITEM.instantiate()
	var item_uid := item.get_instance_id()

	item_container.add_child(item)
	item.remove_requested.connect(func(): remove_item(item))
	item.line_edit.text_changed.connect(
		func(new_text: String): item_text_changed.emit(item_uid, new_text)
	)

	item.line_edit.text = text
	item_added.emit(item_uid)

	return item_uid

func remove_item(item: Control) -> void:
	if item != null and item.has_method("queue_free"):
		item_removed.emit(item.get_instance_id())
		item.queue_free()

func remove_all() -> void:
	for child in item_container.get_children():
		child.queue_free()
