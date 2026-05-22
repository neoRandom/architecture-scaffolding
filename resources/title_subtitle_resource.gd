@tool
class_name TitleSubtitleResource
extends Resource

@export var title: String:
	set(v):
		if title != v:
			title = v
			emit_changed()
@export var subtitle: String:
	set(v):
		if subtitle != v:
			subtitle = v
			emit_changed()
