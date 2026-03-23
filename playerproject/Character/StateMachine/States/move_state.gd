extends BaseState
class_name WalkState

func enter() -> void:
	clear_velocity_buffer()
	machine.play_anim("Walk")

func update(delta: float) -> void:
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		machine.switch_state("JumpState")
		return
	if Input.is_action_pressed("sprint") and not player.state_vars["crouching"]:
		machine.switch_state("SprintState")
		return
	if Input.is_action_pressed("crouch"):
		machine.switch_state("CrouchMoveState")
		return
	if Input.is_action_pressed("aim"):
		machine.switch_state("AimState")
		return
	if not player.is_moving():
		machine.switch_state("IdleState")
