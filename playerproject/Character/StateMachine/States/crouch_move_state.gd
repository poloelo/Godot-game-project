extends BaseState
class_name CrouchMoveState

func enter(delta: float):
	# Initialise le blend_state
	for param_name in machine.animation_blend:
		var param_path = "parameters/%s/blend_amount" % param_name
		if anim_tree.has_method("get") and anim_tree.get(param_path) != null:
			var current = anim_tree.get(param_path)
			if typeof(current) == TYPE_FLOAT:
				blend_state[param_name] = current
	
	# Vide le buffer de vélocité
	velocity_buffer.clear()
	
	# Transition vers l'animation de marche accroupie
	var targets = {
		"Running_top": 0.0,
		"Running_bott": 0.0,
		"Sprint_top": 0.0,
		"Sprint_bott": 0.0,
		"Crouch_top": 0.0,
		"Crouch_bott": 0.0,
		"Crouch_walk_top": 1.0,
		"Crouch_walk_bott": 1.0,
		"Pistol_aiming_top": 0.0,
		"Pistol_aiming_bott": 0.0,
		"Riffle_aiming_top": 0.0,
		"Riffle_aiming_bott": 0.0
	}
	
	machine.apply_blend_targets(targets, delta)

func update(delta: float):
	if not Input.is_action_pressed("crouch"):
		machine.switch_state("MoveState", delta)
		return
		
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		machine.switch_state("JumpState", delta)
		return
		
	if Input.is_action_pressed("aim"):
		if player.current_weapon == "pistol":
			machine.switch_state("PistolAimState", delta)
		else:
			machine.switch_state("RifleAimState", delta)
		return
	
	# Vérifie si le joueur s'arrête tout en étant accroupi
	var avg_velocity = update_velocity_buffer()
	
	if avg_velocity < machine.no_velocity_int * 0.8:
		machine.switch_state("CrouchState", delta)
		return
	
	# Maintient l'animation de marche accroupie
	var targets = {
		"Running_top": 0.0,
		"Running_bott": 0.0,
		"Sprint_top": 0.0,
		"Sprint_bott": 0.0,
		"Crouch_top": 0.0,
		"Crouch_bott": 0.0,
		"Crouch_walk_top": 1.0,
		"Crouch_walk_bott": 1.0,
		"Pistol_aiming_top": 0.0,
		"Pistol_aiming_bott": 0.0,
		"Riffle_aiming_top": 0.0,
		"Riffle_aiming_bott": 0.0
	}
	
	machine.apply_blend_targets(targets, delta)

func exit(delta: float):
	# Sauvegarde l'état actuel du blend pour une transition plus douce
	for param_name in machine.animation_blend:
		var param_path = "parameters/%s/blend_amount" % param_name
		if anim_tree.has_method("get") and anim_tree.get(param_path) != null:
			var current = anim_tree.get(param_path)
			if typeof(current) == TYPE_FLOAT:
				blend_state[param_name] = current
