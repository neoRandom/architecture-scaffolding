extends Control

@onready var step_1: Step1 = %Step1
@onready var step_2: Step2 = %Step2

var current_step := 1

func _ready() -> void:
	_move_to_step_1()
	Command.next_step_required.connect(_handle_next_step_required)

func _handle_next_step_required(reverse: bool) -> void:
	if current_step == 1 and not reverse:
		_move_to_step_2()
		current_step += 1
	if current_step == 2 and reverse:
		_move_to_step_1()
		current_step -= 1

func _move_to_step_1() -> void:
	step_1.visible = true
	step_2.visible = false

func _move_to_step_2() -> void:
	step_2.setup_canvas()

	step_1.visible = false
	step_2.visible = true
