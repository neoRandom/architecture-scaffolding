extends Control

@onready var step_1: Step1 = %Step1
@onready var step_2: Step2 = %Step2

func _ready() -> void:
	_move_to_current_step()
	Command.next_step_required.connect(_handle_next_step_required)
	DataStore.data_deleted.connect(_move_to_current_step)

func _handle_next_step_required(reverse: bool) -> void:
	var new_current_step := DataStore.data.current_step

	new_current_step = new_current_step - 1 if reverse else new_current_step + 1
	new_current_step = clampi(new_current_step, 1, 2)

	DataStore.data.current_step = new_current_step

	_move_to_current_step()

func _move_to_current_step() -> void:
	match DataStore.data.current_step:
		1:
			step_1.setup()
			step_1.visible = true
			step_2.visible = false
		2:
			step_2.setup()
			step_1.visible = false
			step_2.visible = true
