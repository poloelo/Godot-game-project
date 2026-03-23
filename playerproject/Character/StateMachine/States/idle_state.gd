extends BaseState
class_name IdleState

func enter() -> void:
	clear_velocity_buffer()
	machine.play_anim("Idle")

func update(delta: float) -> void:
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		machine.switch_state("JumpState")
		return
	if player.is_moving():
		machine.switch_state("WalkState")
