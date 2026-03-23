extends Node
class_name BaseState

var machine: StateMachine
var player: Player

# Buffer pour lisser la vélocité et éviter les micro-transitions parasites
var _velocity_buffer: Array[float] = []
const BUFFER_SIZE: int = 5
const NO_VELOCITY_THRESHOLD: float = 0.3

func enter() -> void:
	pass

func update(_delta: float) -> void:
	pass

func exit() -> void:
	pass

func get_average_velocity() -> float:
	_velocity_buffer.append(player.get_horizontal_velocity())
	if _velocity_buffer.size() > BUFFER_SIZE:
		_velocity_buffer.pop_front()
	var total := 0.0
	for v in _velocity_buffer:
		total += v
	return total / _velocity_buffer.size()

func clear_velocity_buffer() -> void:
	_velocity_buffer.clear()
