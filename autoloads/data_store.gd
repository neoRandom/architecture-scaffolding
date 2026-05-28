extends Node

const DATA_FILE_PATH := "user://data.save"
const SAVE_TIMER_COOLDOWN := 60

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

class Data:
	var current_id: int = 0
	var components: Array[Component] = []
	var connections: Array[Connection] = []

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

func bootstrap() -> void:
	data = Data.new()

	if not FileAccess.file_exists(DATA_FILE_PATH):
		return

	var data_file := FileAccess.open(DATA_FILE_PATH, FileAccess.READ)
	var saved_data: Dictionary = JSON.parse_string(data_file.get_line())

	data.current_id = saved_data.get(DataFileKeys.CURRENT_ID, 0)
	data.components = saved_data.get(DataFileKeys.COMPONENTS, [])
	data.connections = saved_data.get(DataFileKeys.CONNECTIONS, [])

func set_timer() -> void:
	var timer := Timer.new()
	timer.one_shot = false
	timer.start(SAVE_TIMER_COOLDOWN)

	timer.timeout.connect(save_data)

func save_data() -> void:
	if is_saving == true:
		return
	is_saving = true

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
