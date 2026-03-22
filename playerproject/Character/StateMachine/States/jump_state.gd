extends BaseState
class_name JumpState

func enter() -> void:
	clear_velocity_buffer()
	# Snap immédiat pour éviter un fondu bizarre depuis idle/walk
	machine.snap_to_blends("Jump_top", "Jump_bott_2")

func update(delta: float) -> void:
	if player.is_on_floor():
		if player.is_moving():
			machine.switch_state("WalkState")
		else:
			machine.switch_state("IdleState")
