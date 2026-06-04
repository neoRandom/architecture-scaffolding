class_name Step1
extends Control

@onready var use_cases: TitleSubtitleListAdd = %UseCases
@onready var models: TitleSubtitleListAdd = %Models
@onready var services: TitleSubtitleListAdd = %Services
@onready var driver_adapters: TitleSubtitleListAdd = %DriverAdapters
@onready var driven_adapters: TitleSubtitleListAdd = %DrivenAdapters

var unique_id_to_data_id_relation: Dictionary[int, int] = {}

func _ready() -> void:
	DataStore.deleting_save.connect(
		func():
			use_cases.items.remove_all()
			models.items.remove_all()
			services.items.remove_all()
			driver_adapters.items.remove_all()
			driven_adapters.items.remove_all()
	)

	for component: DataStore.Component in DataStore.data.components:
		var tsla: TitleSubtitleListAdd

		match component.type:
			DataStore.ComponentType.USE_CASE:
				tsla = use_cases
			DataStore.ComponentType.MODEL:
				tsla = models
			DataStore.ComponentType.SERVICE:
				tsla = services
			DataStore.ComponentType.DRIVER_ADAPTER:
				tsla = driver_adapters
			DataStore.ComponentType.DRIVEN_ADAPTER:
				tsla = driven_adapters

		if tsla == null:
			continue

		var uid := tsla.items.add_new_item(component.title)
		unique_id_to_data_id_relation[uid] = component.id

	_setup_tsla(use_cases, DataStore.ComponentType.USE_CASE)
	_setup_tsla(models, DataStore.ComponentType.MODEL)
	_setup_tsla(services, DataStore.ComponentType.SERVICE)
	_setup_tsla(driver_adapters, DataStore.ComponentType.DRIVER_ADAPTER)
	_setup_tsla(driven_adapters, DataStore.ComponentType.DRIVEN_ADAPTER)

func _setup_tsla(tsla: TitleSubtitleListAdd, component_type: DataStore.ComponentType) -> void:
	tsla.items.item_added.connect(
		func(uid: int):
			if _add_item_to_data_store(uid, component_type) == true:
				print("ADDED %d" % uid)
			else:
				print("ERROR ADDING %d" % uid)
	)
	tsla.items.item_removed.connect(
		func(uid: int):
			if _remove_item_from_data_store(uid) == true:
				print("REMOVED %d" % uid)
			else:
				print("ERROR REMOVING %d" % uid)
	)
	tsla.items.item_text_changed.connect(
		func(uid: int, new_text: String):
			if _update_item_title_from_data_store(uid, new_text) == true:
				print("UPDATED %d" % uid)
			else:
				print("ERROR UPDATING %d" % uid)
	)

func _add_item_to_data_store(uid: int, type: DataStore.ComponentType) -> bool:
	var list_item_component: ListItem = instance_from_id(uid)
	if list_item_component == null:
		return false

	var component := DataStore.Component.new()
	component.title = list_item_component.line_edit.text
	component.type = type

	var data_id := DataStore.data.add_component(component)
	unique_id_to_data_id_relation[uid] = data_id

	return true

func _remove_item_from_data_store(uid: int) -> bool:
	var data_id: int = unique_id_to_data_id_relation.get(uid, null)
	if data_id == null:
		return false

	DataStore.data.remove_component(data_id)
	return true

func _update_item_title_from_data_store(uid: int, new_text: String) -> bool:
	var data_id: int = unique_id_to_data_id_relation.get(uid, null)
	if data_id == null:
		return false

	var component := DataStore.data.get_component_by_id(data_id)
	if component == null:
		return false
	component.title = new_text

	return true
