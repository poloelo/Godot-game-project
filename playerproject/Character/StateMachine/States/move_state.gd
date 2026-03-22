extends Node
class_name WalkState

var machine: StateMachine

func enter():
	machine.set_blends("running_top", "running_bott")

func update(delta):
	if not machine.player.is_moving():
		machine.switch_state("IdleState")
	elif Input.is_action_just_pressed("jump"):
		machine.switch_state("JumpState")

func exit():
	pass
