class_name Step1
extends Control

@onready var use_cases: TitleSubtitleListAdd = %UseCases
@onready var models: TitleSubtitleListAdd = %Models
@onready var services: TitleSubtitleListAdd = %Services
@onready var driver_adapters: TitleSubtitleListAdd = %DriverAdapters
@onready var driven_adapters: TitleSubtitleListAdd = %DrivenAdapters

var unique_id_to_data_id_relation: Dictionary[int, int] = {}

func _ready() -> void:
	for component: DataStore.Component in DataStore.data.components:
		match component.type:
			DataStore.ComponentType.USE_CASE:
				use_cases.items.add_new_item(component.title)

	use_cases.items.item_added.connect(
		func(uid: int):
			if add_item_to_data_store(uid, DataStore.ComponentType.USE_CASE) == true:
				print("ADDED %d" % uid)
			else:
				print("ERROR ADDING %d" % uid)
	)
	use_cases.items.item_removed.connect(
		func(uid: int):
			if remove_item_from_data_store(uid) == true:
				print("REMOVED %d" % uid)
			else:
				print("ERROR REMOVING %d" % uid)
	)

func add_item_to_data_store(uid: int, type: DataStore.ComponentType) -> bool:
	var list_item_component: ListItem = instance_from_id(uid)
	if list_item_component == null:
		return false

	var component := DataStore.Component.new()
	component.title = list_item_component.line_edit.text
	component.type = type

	var data_id := DataStore.data.add_component(component)
	unique_id_to_data_id_relation[uid] = data_id

	return true

func remove_item_from_data_store(uid) -> bool:
	var data_id: int = unique_id_to_data_id_relation.get(uid, null)
	if data_id == null:
		return false

	DataStore.data.remove_component(data_id)
	return true
