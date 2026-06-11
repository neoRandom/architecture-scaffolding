extends Node

signal data_deleted
signal data_saved
signal data_loaded
signal data_exported

const DATA_FILE_PATH := "user://data.save"
const AUTOSAVE_COOLDOWN := 30

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
	var position: Vector2
	var size: Vector2

	func to_dict() -> Dictionary:
		return {
			"id": id,
			"type": type,
			"title": title,
			"position": position,
			"size": size
		}

	static func from_dict(dict: Dictionary) -> Component:
		var new_component := Component.new()

		if dict.has("id"):
			new_component.id = dict["id"]
		if dict.has("type"):
			new_component.type = dict["type"] as ComponentType
		if dict.has("title"):
			new_component.title = dict["title"]
		if dict.has("position"):
			new_component.position = Utils.string_to_vector2(dict["position"])
		if dict.has("size"):
			new_component.size = Utils.string_to_vector2(dict["size"])

		return new_component

class Connection:
	var id: int = 0
	var from_id: int
	var from_port: int
	var to_id: int
	var to_port: int

	func to_dict() -> Dictionary:
		return {
			"id": id,
			"from_id": from_id,
			"from_port": from_port,
			"to_id": to_id,
			"to_port": to_port
		}

	static func from_dict(dict: Dictionary) -> Connection:
		var new_connection := Connection.new()

		if dict.has("id"):
			new_connection.id = dict["id"]
		if dict.has("from_id"):
			new_connection.from_id = dict["from_id"]
		if dict.has("from_port"):
			new_connection.from_port = dict["from_port"]
		if dict.has("to_id"):
			new_connection.to_id = dict["to_id"]
		if dict.has("to_port"):
			new_connection.to_port = dict["to_port"]

		return new_connection

class Data:
	var current_step: int = 1
	var current_id: int = 0
	var camera_zoom: float = 1.0
	var camera_offset: Vector2
	var components: Array[Component] = []
	var connections: Array[Connection] = []

	# ===
	func add_component(component: Component) -> int:
		current_id += 1
		component.id = current_id
		components.append(component)
		return component.id

	func remove_component(id: int) -> void:
		var component_connections := connections.filter(
			func(connection) -> bool:
				return connection.from_id == id or connection.to_id == id
		)
		for connection in component_connections:
			remove_connection(connection.id)

		var idx := components.find_custom(
			func(component: Component):
				return component.id == id
		)
		components.remove_at(idx)

	func get_component_by_id(id: int) -> Component:
		var idx := components.find_custom(
			func(component: Component):
				return component.id == id
		)
		return components.get(idx)

	# ===
	func add_connection(connection: Connection) -> int:
		current_id += 1
		connection.id = current_id
		connections.append(connection)
		return connection.id

	func remove_connection(id: int) -> void:
		var idx := connections.find_custom(
			func(connection: Connection):
				return connection.id == id
		)
		connections.remove_at(idx)


@abstract
class DataFileKeys:
	const CURRENT_STEP: String = "current_step"
	const CURRENT_ID: String = "current_id"
	const CAMERA_ZOOM: String = "camera_zoom"
	const CAMERA_OFFSET: String = "camera_offset"
	const COMPONENTS: String = "components"
	const CONNECTIONS: String = "connections"

# ===

var autosave_timer := Timer.new()
var data: Data
var can_save: bool = false

func _ready() -> void:
	bootstrap()
	set_timer()

func bootstrap() -> void:
	can_save = false
	data = Data.new()

	if not FileAccess.file_exists(DATA_FILE_PATH):
		return

	var data_file := FileAccess.open(DATA_FILE_PATH, FileAccess.READ)
	if data_file.get_length() == 0:
		return

	var saved_data: Dictionary = JSON.parse_string(data_file.get_line())
	var saved_components: Array = saved_data.get(DataFileKeys.COMPONENTS, [])
	var saved_connections: Array = saved_data.get(DataFileKeys.CONNECTIONS, [])

	data.current_step = saved_data.get(DataFileKeys.CURRENT_STEP, 1)
	data.current_id = saved_data.get(DataFileKeys.CURRENT_ID, 0)
	data.camera_zoom = saved_data.get(DataFileKeys.CAMERA_ZOOM, 1.0)
	if saved_data.has(DataFileKeys.CAMERA_OFFSET):
		data.camera_offset = Utils.string_to_vector2(saved_data.get(DataFileKeys.CAMERA_OFFSET))

	for saved_component in saved_components:
		data.components.append(Component.from_dict(saved_component))
	for saved_connection in saved_connections:
		data.connections.append(Connection.from_dict(saved_connection))

	can_save = true

func set_timer() -> void:
	autosave_timer.wait_time = AUTOSAVE_COOLDOWN
	autosave_timer.one_shot = false
	autosave_timer.autostart = true

	autosave_timer.timeout.connect(save_data)
	get_tree().current_scene.add_child(autosave_timer)

func save_data() -> void:
	if can_save == false or data == null:
		return

	can_save = false
	print("SAVING DATA...")

	var data_file := FileAccess.open(DATA_FILE_PATH, FileAccess.WRITE)
	var temp_save_data := {
		DataFileKeys.CURRENT_STEP: data.current_step,
		DataFileKeys.CURRENT_ID: data.current_id,
		DataFileKeys.CAMERA_ZOOM: data.camera_zoom,
		DataFileKeys.CAMERA_OFFSET: data.camera_offset,
		DataFileKeys.COMPONENTS: [],
		DataFileKeys.CONNECTIONS: []
	}

	for component in data.components:
		temp_save_data[DataFileKeys.COMPONENTS].append(component.to_dict())

	for connection in data.connections:
		temp_save_data[DataFileKeys.CONNECTIONS].append(connection.to_dict())

	print(JSON.stringify(temp_save_data, "\t"))
	data_file.store_line(JSON.stringify(temp_save_data))

	can_save = true
	autosave_timer.wait_time = AUTOSAVE_COOLDOWN
	data_saved.emit()
	print("DATA SAVED")

func delete_save() -> void:
	if not FileAccess.file_exists(DATA_FILE_PATH):
		print("Save File does not exist: %s" % DATA_FILE_PATH)
		return

	var error = DirAccess.remove_absolute(DATA_FILE_PATH)
	if error != OK:
		print("FAILED TO DELETE DATA FILE: ", error)
		return

	data = Data.new()
	data_deleted.emit()
	print("DATA FILE DELETED")

func load_save(source_path: String) -> void:
	can_save = false

	if not FileAccess.file_exists(source_path):
		print("Error: Source file does not exist at " + source_path)
		return

	# Open directory access
	var dir = DirAccess.open("res://") # Base directory context
	if dir:
		var error = dir.copy(source_path, DATA_FILE_PATH)

		if error == OK:
			print("Save File loaded successfully")
			bootstrap()
			data_loaded.emit()
		else:
			print("Failed to load file. Error code: ", error)
	else:
		print("Failed to access the directory system.")

	can_save = true

func export_save(save_path: String) -> void:
	save_data()

	var dir = DirAccess.open("res://") # Base directory context
	if dir:
		var error = dir.copy(DATA_FILE_PATH, save_path)

		if error == OK:
			print("Save File exported successfully")
			data_exported.emit()
		else:
			print("Failed to load file. Error code: ", error)
	else:
		print("Failed to access the directory system.")
