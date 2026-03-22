extends Node
class_name JumpState

var machine: StateMachine

func enter():
	machine.set_blends("jumping_top", "jumping_bott")

func update(delta):
	if machine.player.is_on_floor():
		machine.switch_state("IdleState") # ou WalkState selon ta logique

func exit():
	pass
