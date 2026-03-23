extends BaseState
class_name JumpState

func enter() -> void:
	clear_velocity_buffer()
	machine.play_anim("Jump")

func update(delta: float) -> void:
	if player.is_on_floor():
		if player.is_moving():
			machine.switch_state("WalkState")
		else:
			machine.switch_state("IdleState")
