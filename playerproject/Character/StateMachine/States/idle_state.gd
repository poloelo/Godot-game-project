extends Node
class_name IdleState

var machine: StateMachine

func enter():
	machine.set_blends("idle_top", "idle_bott")

func update(delta):
	if machine.player.is_moving():
		machine.switch_state("WalkState")
	elif Input.is_action_just_pressed("jump"):
		machine.switch_state("JumpState")

func exit():
	pass
