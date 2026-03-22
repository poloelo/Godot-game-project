extends Node3D

@export var mouse_sensitivity: float = 30.0
@export var min_pitch: float = -45.0
@export var max_pitch: float = 60.0
# Vitesse de lissage de la caméra. 0 = aucun lissage (raw), 30 = très lisse.
@export var smoothing_speed: float = 25.0

@onready var character: CharacterBody3D = $"../CharacterBody3D"
@onready var x_pivot: Node3D = $x_pivot

# Cibles accumulées depuis les events souris (en radians)
var _target_yaw: float = 0.0
var _target_pitch: float = 0.0

# Valeurs actuelles interpolées (appliquées à la scène)
var _current_yaw: float = 0.0
var _current_pitch: float = 0.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouseMotion:
		return
	# Accumule uniquement la cible — pas de lerp ici, c'est dans _process
	var sensitivity := mouse_sensitivity * 0.001
	_target_yaw   -= event.relative.x * sensitivity
	_target_pitch -= event.relative.y * sensitivity
	_target_pitch = clamp(_target_pitch, deg_to_rad(min_pitch), deg_to_rad(max_pitch))

func _process(delta: float) -> void:
	# Suit la position du personnage
	position = character.position + Vector3(0.0, 0.3, 0.0)

	# Interpolation delta-based : résultat identique à tous les framerates
	var t := clamp(smoothing_speed * delta, 0.0, 1.0)
	_current_yaw   = lerp_angle(_current_yaw,  _target_yaw,  t)
	_current_pitch = lerpf(_current_pitch, _target_pitch, t)

	# Yaw appliqué sur ce noeud (Pivot horizontal)
	rotation.y = _current_yaw
	# Pitch appliqué sur l'enfant x_pivot (évite le gimbal lock)
	x_pivot.rotation.x = _current_pitch
