extends BaseState
class_name AimState

func enter() -> void:
	clear_velocity_buffer()
	_apply_blend_for_weapon()

func update(delta: float) -> void:
	if not Input.is_action_pressed("aim"):
		if player.is_moving():
			if Input.is_action_pressed("sprint"):
				machine.switch_state("SprintState")
			else:
				machine.switch_state("WalkState")
		else:
			machine.switch_state("IdleState")
		return
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		machine.switch_state("JumpState")
		return
	# Si le joueur change d'arme pendant la visée, met à jour le blend
	if Input.is_action_just_pressed("switch_weapon"):
		_apply_blend_for_weapon()

func exit() -> void:
	pass

func _apply_blend_for_weapon() -> void:
	if player.current_weapon == "pistol":
		machine.set_blends("Pistol Aiming Top", "Pistol Aiming Bott")
	else:
		machine.set_blends("Riffle Aiming Top", "Riffle Aiming Bott")
