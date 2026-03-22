extends Node
class_name BaseState

# Assignés par StateMachine._ready()
var machine: StateMachine
var player: Player

# Buffer de vélocité pour des transitions stables (évite les flickering)
var _velocity_buffer: Array[float] = []
const BUFFER_SIZE: int = 5

func enter() -> void:
	pass

func update(delta: float) -> void:
	pass

func exit() -> void:
	pass

# Retourne la vélocité horizontale moyenne sur les dernières frames.
# Utilisé pour éviter les transitions prématurées dues à des pics de vélocité.
func get_average_velocity() -> float:
	var current := player.get_horizontal_velocity()
	_velocity_buffer.append(current)
	if _velocity_buffer.size() > BUFFER_SIZE:
		_velocity_buffer.pop_front()
	var total := 0.0
	for v in _velocity_buffer:
		total += v
	return total / _velocity_buffer.size()

func clear_velocity_buffer() -> void:
	_velocity_buffer.clear()
