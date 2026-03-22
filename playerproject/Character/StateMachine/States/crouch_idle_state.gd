extends BaseState
class_name CrouchState

func enter() -> void:
	clear_velocity_buffer()
	machine.set_blends("Crouch Top", "Crouch Bott")

func update(delta: float) -> void:
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		machine.switch_state("JumpState")
		return
	if not Input.is_action_pressed("crouch"):
		machine.switch_state("IdleState")
		return
	if Input.is_action_pressed("aim"):
		machine.switch_state("AimState")
		return
	var avg_velocity := get_average_velocity()
	if avg_velocity > StateMachine.NO_VELOCITY_THRESHOLD * 1.2:
		machine.switch_state("CrouchMoveState")

func exit() -> void:
	pass
