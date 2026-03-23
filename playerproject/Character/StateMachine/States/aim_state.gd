extends BaseState
class_name AimState

func enter() -> void:
	clear_velocity_buffer()
	_play_weapon_anim()

func update(delta: float) -> void:
	if not Input.is_action_pressed("aim"):
		if player.is_moving():
			machine.switch_state("SprintState" if Input.is_action_pressed("sprint") else "WalkState")
		else:
			machine.switch_state("IdleState")
		return
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		machine.switch_state("JumpState")
		return
	if Input.is_action_just_pressed("switch_weapon"):
		_play_weapon_anim()

func _play_weapon_anim() -> void:
	machine.play_anim("PistolAim" if player.current_weapon == "pistol" else "RifleAim")
