@tool
class_name ComponentGraphNode
extends GraphNode

@onready var component_name: LineEdit = %ComponentName

const COMPONENT_GRAPH_NODE_TITLEBAR_STYLE_1 := preload("uid://d0vd627sqy882")
const COMPONENT_GRAPH_NODE_TITLEBAR_SELECTED_STYLE_1 := preload("uid://nwe50kq63bey")

const COMPONENT_GRAPH_NODE_TITLEBAR_STYLE_2 := preload("uid://ccdoov1casoe")
const COMPONENT_GRAPH_NODE_TITLEBAR_SELECTED_STYLE_2 := preload("uid://dkks26y2al5u1")

const COMPONENT_GRAPH_NODE_TITLEBAR_STYLE_3 := preload("uid://dnl8r16ul70jv")
const COMPONENT_GRAPH_NODE_TITLEBAR_SELECTED_STYLE_3 := preload("uid://c8kjaedt5cbb3")

const COMPONENT_GRAPH_NODE_TITLEBAR_STYLE_4 := preload("uid://cib77gqqnmyr6")
const COMPONENT_GRAPH_NODE_TITLEBAR_SELECTED_STYLE_4 := preload("uid://wed5ri52ayy5")

const COMPONENT_GRAPH_NODE_TITLEBAR_STYLE_5 := preload("uid://jb7u5gp4s80f")
const COMPONENT_GRAPH_NODE_TITLEBAR_SELECTED_STYLE_5 := preload("uid://bs1p67y3beawf")

var type: DataStore.ComponentType

func set_style(style_type: DataStore.ComponentType) -> void:
	type = style_type

	match type:
		DataStore.ComponentType.USE_CASE:
			set_titlebar(
				"Use Case",
				COMPONENT_GRAPH_NODE_TITLEBAR_STYLE_1,
				COMPONENT_GRAPH_NODE_TITLEBAR_SELECTED_STYLE_1
			)
		DataStore.ComponentType.MODEL:
			set_titlebar(
				"Model",
				COMPONENT_GRAPH_NODE_TITLEBAR_STYLE_2,
				COMPONENT_GRAPH_NODE_TITLEBAR_SELECTED_STYLE_2
			)
		DataStore.ComponentType.SERVICE:
			set_titlebar(
				"Service",
				COMPONENT_GRAPH_NODE_TITLEBAR_STYLE_3,
				COMPONENT_GRAPH_NODE_TITLEBAR_SELECTED_STYLE_3
			)
		DataStore.ComponentType.DRIVER_ADAPTER:
			set_titlebar(
				"Driver Adapter",
				COMPONENT_GRAPH_NODE_TITLEBAR_STYLE_4,
				COMPONENT_GRAPH_NODE_TITLEBAR_SELECTED_STYLE_4
			)
		DataStore.ComponentType.DRIVEN_ADAPTER:
			set_titlebar(
				"Driven Adapter",
				COMPONENT_GRAPH_NODE_TITLEBAR_STYLE_5,
				COMPONENT_GRAPH_NODE_TITLEBAR_SELECTED_STYLE_5
			)

func set_titlebar(type_title: String, normal_style: StyleBoxFlat, selected_style: StyleBoxFlat) -> void:
	title = type_title
	add_theme_stylebox_override("titlebar", normal_style)
	add_theme_stylebox_override("titlebar_selected", selected_style)
