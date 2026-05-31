extends Node

const DATA_FILE_PATH := "user://data.save"
const SAVE_TIMER_COOLDOWN := 5

# ===

enum ComponentType {
	USE_CASE,
	MODEL,
	SERVICE,
	DRIVER_ADAPTER,
	DRIVEN_ADAPTER,

	DRIVER_PORT,
	DRIVEN_PORT,
	DATA_TRANSFER_OBJECT,

	CONNECTION
}

# ===

class Component:
	var id: int = 0
	var type: ComponentType
	var title: String

	func to_dict() -> Dictionary:
		return {
			"id": id,
			"type": type,
			"title": title
		}

	static func from_dict(dict: Dictionary) -> Component:
		var new_component := Component.new()
		var d_id: int = dict.get("id")
		if d_id != null:
			new_component.id = d_id
		var d_type: int = dict.get("type")
		if d_type != null:
			new_component.type = d_type as ComponentType
		var d_title: String = dict.get("title")
		if d_title != null:
			new_component.title = d_title

		return new_component

class Connection:
	var id: int = 0
	var from_id: int
	var to_id: int

	func to_dict() -> Dictionary:
		return {
			"id": id,
			"from_id": from_id,
			"to_id": to_id
		}

	static func from_dict(dict: Dictionary) -> Connection:
		var new_connection := Connection.new()
		var d_id: int = dict.get("id")
		if d_id != null:
			new_connection.id = d_id
		var d_from_id: int = dict.get("from_id")
		if d_from_id != null:
			new_connection.from_id = d_from_id
		var d_to_id: int = dict.get("to_id")
		if d_to_id != null:
			new_connection.to_id = d_to_id
		return new_connection

class Data:
	var current_id: int = 0
	var components: Array[Component] = []
	var connections: Array[Connection] = []

	func add_component(component: Component) -> int:
		current_id += 1
		component.id = current_id
		components.append(component)
		return component.id

	func remove_component(id: int) -> void:
		var idx := components.find_custom(
			func(component: Component):
				return component.id == id
		)
		components.remove_at(idx)

@abstract
class DataFileKeys:
	const CURRENT_ID: String = "current_id"
	const COMPONENTS: String = "components"
	const CONNECTIONS: String = "connections"

# ===

var data: Data
var is_saving: bool = false

func _ready() -> void:
	bootstrap()
	set_timer()

func bootstrap() -> void:
	data = Data.new()

	if not FileAccess.file_exists(DATA_FILE_PATH):
		return

	var data_file := FileAccess.open(DATA_FILE_PATH, FileAccess.READ)
	if data_file.get_length() == 0:
		return

	var saved_data: Dictionary = JSON.parse_string(data_file.get_line())
	var saved_components: Array = saved_data.get(DataFileKeys.COMPONENTS, [])
	var saved_connections: Array = saved_data.get(DataFileKeys.CONNECTIONS, [])

	data.current_id = saved_data.get(DataFileKeys.CURRENT_ID, 0)
	for saved_component in saved_components:
		data.components.append(Component.from_dict(saved_component))
	for saved_connection in saved_connections:
		data.connections.append(Connection.from_dict(saved_connection))

func set_timer() -> void:
	var timer := Timer.new()
	timer.wait_time = SAVE_TIMER_COOLDOWN
	timer.one_shot = false
	timer.autostart = true

	timer.timeout.connect(save_data)
	get_tree().current_scene.add_child(timer)

func save_data() -> void:
	if is_saving == true or data == null:
		return
	is_saving = true
	print("SAVING DATA...")

	var data_file := FileAccess.open(DATA_FILE_PATH, FileAccess.WRITE)
	var temp_save_data := {
		DataFileKeys.CURRENT_ID: 0,
		DataFileKeys.COMPONENTS: [],
		DataFileKeys.CONNECTIONS: []
	}

	for component in data.components:
		temp_save_data[DataFileKeys.COMPONENTS].append(component.to_dict())

	for connection in data.connections:
		temp_save_data[DataFileKeys.CONNECTIONS].append(connection.to_dict())

	data_file.store_line(JSON.stringify(temp_save_data))

	is_saving = false
	print("DATA SAVED")
