class_name Step2
extends Control

@onready var graph_edit: GraphEdit = %GraphEdit

var selected_nodes: Dictionary[int, Node] = {}
var copied_nodes: Array[Node] = []

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
		graph_edit.add_child(node.duplicate()) # Duplicates a second time


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
	print(selected_nodes)


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
