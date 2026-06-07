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

	var node_gap := graph_edit.snapping_distance
	var max_row_size := ceili(sqrt(DataStore.data.components.size()))

	var node_layout_offset := Vector2(0.0, MYSTERIOUS_Y_OFFSET)
	var rows := 1
	var layout_size := Vector2.ZERO

	#
	for i in DataStore.data.components.size():
		var component = DataStore.data.components[i]
		if component.position == null:
			component.position = Vector2.ZERO

		#
		var new_graph_node: ComponentGraphNode = COMPONENT_GRAPH_NODE.instantiate()
		var node_size_offset := Vector2(new_graph_node.size.x / 2, new_graph_node.size.y / 2)

		graph_edit.add_child(new_graph_node)
		new_graph_node.component_name.text = component.title
		new_graph_node.position_offset = component.position + node_layout_offset - node_size_offset

		new_graph_node.set_style(component.type)

		# Track the layout size so the camera can be centered later
		if node_layout_offset.x > layout_size.x:
			layout_size.x = node_layout_offset.x
		if node_layout_offset.y > layout_size.y:
			layout_size.y = node_layout_offset.y

		# Start a new row to not overflow the current one
		#
		# i + 1 : turns 0-based into 1-based indexing to properly compare it with max row size
		# / rows : makes the comparison be row-independent
		var current_row_size := (i + 1) / (rows as float)
		if current_row_size >= max_row_size:
			node_layout_offset.x = 0.0
			node_layout_offset.y += new_graph_node.size.y + node_gap
			rows += 1
		else:
			node_layout_offset.x += new_graph_node.size.x + node_gap

	# TODO: Load node connections from DataStore
	#

	var offset_to_center_camera := Vector2(-graph_edit.size.x / 2, -graph_edit.size.y / 2)
	offset_to_center_camera += Vector2(layout_size.x / 2, layout_size.y / 2)
	graph_edit.scroll_offset = offset_to_center_camera

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
