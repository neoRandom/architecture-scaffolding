extends Control

@onready var step_1: Step1 = %Step1
@onready var step_2: Step2 = %Step2

func _ready() -> void:
	step_1.visible = true
	step_2.visible = false
