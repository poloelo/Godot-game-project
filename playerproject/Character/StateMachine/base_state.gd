extends Node
class_name BaseState

var machine: StateMachine
var anim_tree: AnimationTree
var player: Player
var velocity_buffer: Array = []
var buffer_size: int = 5
var blend_state: Dictionary = {}

func enter(delta: float):
	# À implémenter dans les classes filles
	pass

func update(delta: float):
	# À implémenter dans les classes filles
	pass

func exit(delta: float):
	# À implémenter dans les classes filles
	pass

func update_velocity_buffer() -> float:
	# Ajoute la vélocité actuelle au buffer
	var current_velocity = player.get_horizontal_velocity()
	velocity_buffer.append(current_velocity)
	
	# Maintient la taille du buffer
	if velocity_buffer.size() > buffer_size:
		velocity_buffer.pop_front()
	
	# Calcule la moyenne des vélocités pour une détection plus stable
	var avg_velocity = 0.0
	for vel in velocity_buffer:
		avg_velocity += vel
	
	return avg_velocity / (velocity_buffer.size() if velocity_buffer.size() > 0 else 1.0)
