class_name Step2
extends Control

@onready var graph_edit: GraphEdit = %GraphEdit

var selected_nodes: Dictionary[int, Node] = {}
var copied_nodes: Array[Node] = []

const MYSTERIOUS_Y_OFFSET := 4 # without it, the nodes will spawn 4 pixels above the grid
const COMPONENT_GRAPH_NODE := preload("uid://brim8mxtpg62j")

# ====================================

func _ready() -> void:
	DataStore.save_deleted.connect(clear)

func clear() -> void:
	for node in graph_edit.get_children():
		if node is not ComponentGraphNode:
			continue
		node.queue_free()

func setup() -> void:
	clear()

	# Can't be const because snapping_distance isn't a constant
	var node_gap := graph_edit.snapping_distance

	var n_node_offset := Vector2(0.0, MYSTERIOUS_Y_OFFSET)
	var max_node_offset := Vector2.ZERO # shows how far the xy node offset goes

	# Necessary for the cubic shape that the nodes will form
	var rows := 1
	var component_qt_root := ceili(sqrt(DataStore.data.components.size()))

	#
	for i in DataStore.data.components.size():
		var component = DataStore.data.components[i]

		if component.position == null:
			component.position = Vector2.ZERO

		#
		var new_graph_node: ComponentGraphNode = COMPONENT_GRAPH_NODE.instantiate()
		var node_size_offset := Vector2(new_graph_node.size.x / 2, new_graph_node.size.y / 2)

		graph_edit.add_child(new_graph_node)
		new_graph_node.title = component.title
		new_graph_node.position_offset = component.position + n_node_offset - node_size_offset

		# We need to calculate the maximum node offset to center the camera later on
		if n_node_offset.x > max_node_offset.x:
			max_node_offset.x = n_node_offset.x
		if n_node_offset.y > max_node_offset.y:
			max_node_offset.y = n_node_offset.y

		#
		if (i + 1) / (rows as float) >= component_qt_root:
			n_node_offset.x = 0.0
			n_node_offset.y += new_graph_node.size.y + node_gap
			rows += 1
		else:
			n_node_offset.x += new_graph_node.size.x + node_gap

		new_graph_node.set_style(component.type)

	# TODO: Add connections from DataStore too

	var window_offset := Vector2(-graph_edit.size.x / 2, -graph_edit.size.y / 2)
	window_offset += Vector2(max_node_offset.x / 2, max_node_offset.y / 2)
	graph_edit.scroll_offset = window_offset

# ====================================

# Column order from left to right
const node_x_offset_order_by_type := [
	DataStore.ComponentType.DRIVER_ADAPTER,
	DataStore.ComponentType.USE_CASE,
	DataStore.ComponentType.SERVICE,
	DataStore.ComponentType.MODEL,
	DataStore.ComponentType.DRIVEN_ADAPTER,
]

func _on_order_by_type_button_pressed() -> void:
	# Can't be const because snapping_distance isn't a constant
	var node_gap := graph_edit.snapping_distance

	var nodes_by_type: Dictionary[DataStore.ComponentType, Array] = {}

	for type in node_x_offset_order_by_type:
		nodes_by_type[type] = []

	for child in graph_edit.get_children():
		if child is ComponentGraphNode:
			nodes_by_type[child.type].append(child)

	var node_offset := Vector2.ZERO
	for type in node_x_offset_order_by_type:
		node_offset.y = 0

		var nodes: Array = nodes_by_type[type]
		if nodes.is_empty():
			continue

		var current_column_width := 0.0
		for node in nodes:
			node.position_offset = node_offset
			node_offset.y += node.size.y + node_gap
			if node.size.x > current_column_width:
				current_column_width = node.size.x

		node_offset.x += current_column_width + node_gap

# ====================================
# ====        CONNECTIONS         ====
# ====================================

func _on_graph_edit_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	graph_edit.connect_node(from_node, from_port, to_node, to_port)


func _on_graph_edit_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	graph_edit.disconnect_node(from_node, from_port, to_node, to_port)

# ====================================
# ==== COPY CUT DUPE PASTE DELETE ====
# ====================================

func _on_graph_edit_copy_nodes_request() -> void:
	copied_nodes.clear()
	for uid in selected_nodes.keys():
		var node: Node = instance_from_id(uid)
		if node == null:
			return
		copied_nodes.append(node.duplicate())


func _on_graph_edit_duplicate_nodes_request() -> void:
	for uid in selected_nodes.keys():
		var node: Node = instance_from_id(uid)
		if node == null:
			return
		graph_edit.add_child(node.duplicate())


func _on_graph_edit_paste_nodes_request() -> void:
	for node in copied_nodes:
		if node == null:
			return
		# Duplicates a second time to not have the same reference as the one
		# stored in the copied_nodes array
		graph_edit.add_child(node.duplicate())


func _on_graph_edit_delete_nodes_request(nodes: Array[StringName]) -> void:
	for node_path in nodes:
		var node := graph_edit.get_node(NodePath(node_path))
		selected_nodes.erase(node.get_instance_id())
		node.queue_free()

# ====================================
# ====  SELECTION / DESELECTION   ====
# ====================================

func _on_graph_edit_node_selected(node: Node) -> void:
	var unique_id := node.get_instance_id()
	if unique_id in selected_nodes.keys():
		return

	selected_nodes[unique_id] = node


func _on_graph_edit_node_deselected(node: Node) -> void:
	var unique_id := node.get_instance_id()
	if unique_id not in selected_nodes.keys():
		return

	selected_nodes.erase(unique_id)

# ====================================
# ==== POP UP / RIGHT CLICK MENU  ====
# ====================================

func _on_graph_edit_popup_request(at_position: Vector2) -> void:
	pass # TODO: Replace with function body.
