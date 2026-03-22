extends State
class_name AimState

@export var blend_speed: float = 5.0
@export var weapon_type: String = "Pistol"  # "Pistol" ou "Riffle"

func enter(delta):
	var top_anim = weapon_type + "_aiming_top"
	var bottom_anim = weapon_type + "_aiming_bott"
	machine.reset_animations([top_anim, bottom_anim])

func process(delta):
	var top_anim = weapon_type + "_aiming_top"
	var bottom_anim = weapon_type + "_aiming_bott"
	
	# Animer l'état visée
	machine.lerp_animation(top_anim, 1.0, delta, blend_speed)
	machine.lerp_animation(bottom_anim, 1.0, delta, blend_speed)
	
	# Vérifier les transitions
	if not Input.is_action_pressed("aim"):
		if is_moving():
			if Input.is_action_pressed("sprint"):
				machine.switch_state($"../SprintState")
			else:
				machine.switch_state($"../MoveState")
		else:
			machine.switch_state($"../IdleState")
	elif Input.is_action_just_pressed("jump") and is_on_floor():
		machine.switch_state($"../JumpState")

func handle_input(event):
	# Changer d'arme si nécessaire
	if Input.is_action_just_pressed("switch_weapon"):
		weapon_type = "Riffle" if weapon_type == "Pistol" else "Pistol"
		
		# Réinitialiser les animations pour la nouvelle arme
		var top_anim = weapon_type + "_aiming_top"
		var bottom_anim = weapon_type + "_aiming_bott"
		machine.reset_animations([top_anim, bottom_anim])

func exit(delta):
	pass
