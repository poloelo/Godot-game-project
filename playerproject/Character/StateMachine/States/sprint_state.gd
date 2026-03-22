extends BaseState
class_name SprintState

func enter() -> void:
	clear_velocity_buffer()
	# Transition rapide vers le sprint (speed_override plus élevé = fondu plus vif)
	machine.set_blends("Sprint Top", "Sprint Bott", 14.0)

func update(delta: float) -> void:
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		machine.switch_state("JumpState")
		return
	if Input.is_action_pressed("crouch"):
		machine.switch_state("CrouchMoveState")
		return
	if Input.is_action_pressed("aim"):
		machine.switch_state("AimState")
		return
	if not Input.is_action_pressed("sprint"):
		machine.switch_state("WalkState")
		return
	var avg_velocity := get_average_velocity()
	if avg_velocity < StateMachine.NO_VELOCITY_THRESHOLD:
		machine.switch_state("IdleState")

func exit() -> void:
	pass
