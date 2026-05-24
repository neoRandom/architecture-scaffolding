@tool
extends Control

@export var resource: TitleSubtitleResource:
	set(new_res):
		resource = new_res
		update()
		if resource != null and not resource.changed.is_connected(update):
			resource.changed.connect(update)

@onready var items: ListAdd = %ListAdd

func _ready() -> void:
	update()

func update() -> void:
	if resource == null:
		return

	%Title.text = resource.title
	%Subtitle.text = resource.subtitle
