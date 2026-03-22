extends Node3D

@export var mouse_sensitivity : float = 30
var mouse_sensitivity_x: float = 0.20/15*mouse_sensitivity # Ajuste la sensibilité pour plus de fluidité
var mouse_sensitivity_y: float = 0.05/15*mouse_sensitivity
@export var camera_offset := Vector3(0, 2, -5)  # Position par défaut de la caméra
@export var min_distance := 1.5        
@export var min_pitch: float = -45.0  # Limite inférieure de la rotation verticale ajustée
@export var max_pitch: float = 60.0   # Limite supérieure de la rotation verticale ajustée

var yaw: float = 0.0
var pitch: float = 0.0
@onready var Character : CharacterBody3D = $"../CharacterBody3D"# Accès à la caméra pour manipuler ses rotations
@onready var camera = $x_pivot

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta) -> void:
	# Positionne la caméra à la position du personnage (sans impacter la rotation du personnage)
	position = Character.position + Vector3(0,0.3,0)
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Met à jour yaw et pitch en fonction du mouvement de la souris et de la sensibilité
		yaw -= event.relative.x * -mouse_sensitivity_x
		pitch -= event.relative.y * -mouse_sensitivity_y

		# Limite pitch aux valeurs définies pour éviter la rotation excessive
		pitch = clamp(pitch, min_pitch, max_pitch)

		# Applique une rotation fluide avec les fonctions de rotation pour une interpolation naturelle sur la caméra uniquement
		# Axe vertical (pitch)
		var target_pitch = lerp(rotation_degrees.x, pitch, 0.5)
		rotation_degrees.x = target_pitch

		# Axe horizontal (yaw)
		var target_yaw = lerp(rotation_degrees.y, -yaw, 0.5)
		rotation_degrees.y = target_yaw
