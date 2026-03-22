extends CharacterBody3D
class_name Player

# --- Propriétés du joueur ---
var vie: int = 100

# --- Paramètres exposés éditeur ---
@export var speed: float = 1.0
@export var jump_count: int = 1
@export var jump_height: float = 5.0
@export var gravity_multiplier: float = 1.0
@export var sprint_speed_multiplier: float = 1.8
@export var crouch_speed_multiplier: float = 0.6

# --- Références ---
@onready var pivot: Node3D = $"../Pivot"
@onready var camera: Camera3D = $"../Pivot/x_pivot/Camera3D"
@onready var state_machine: StateMachine = $StateMachine
@onready var mesh_pointeur: Node3D = $Mesh_pointeur # Point devant toi pour grab

# --- Variables internes ---
var type_perso = "player"
var area_overlapping: RigidBody3D = null   # Objet détecté (Zone de pickup)
var grabbed_object: RigidBody3D = null     # Objet actuellement attrapé
var jumps_remaining: int = 0
var mouse_captured: bool = true
var current_weapon: String = "pistol"  # "pistol" ou "rifle"
var state_vars = {
	"sprinting": false,
	"crouching": false,
	"aiming": false,
	"jumping": false
}
var target_direction: Vector3 = Vector3.ZERO
var direction: Vector3 = Vector3.ZERO
const TRANSITION_SPEED: float = 15.0

# --- READY ---
func _ready() -> void:
	global_transform.origin = Vector3(11, 11, 11)
	jumps_remaining = jump_count
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# --- INPUT ---
func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("exit"):
		toggle_mouse_capture()
	if Input.is_action_pressed("switch_weapon"):
		toggle_weapon()
	# --- Début du grab ---
	if Input.is_action_just_pressed("grab") and area_overlapping and area_overlapping is RigidBody3D:
		grabbed_object = area_overlapping
		grabbed_object.gravity_scale = 0.0 # Plus léger à porter
		grabbed_object.freeze = false      # On s'assure qu'il bouge

	# --- Fin du grab ---
	if Input.is_action_just_released("grab") and grabbed_object:
		grabbed_object.gravity_scale = 1.0
		grabbed_object = null

# --- PHYSICS ---
func _physics_process(delta: float) -> void:
	update_state_vars()
	handle_movement(delta)
	handle_aiming()
	interact()
	move_and_slide()

	var offset = -camera.global_transform.basis.z.normalized() * 3.0  # 3 unités devant la cam
	mesh_pointeur.global_transform.origin = camera.global_transform.origin + offset
	handle_grab(delta)

# --- FONCTION GRAB (Half-Life) ---
func handle_grab(delta: float) -> void:
	if grabbed_object:
		var target_pos = mesh_pointeur.global_transform.origin
		var obj_pos = grabbed_object.global_transform.origin
		var to_target = target_pos - obj_pos

		# On veut aller vers target_pos, mais on lerp la velocity pour éviter l’effet "violent"
		var desired_velocity = to_target * 10.0  # 10.0 = force d’attraction
		grabbed_object.linear_velocity = grabbed_object.linear_velocity.lerp(desired_velocity, 0.2)
		grabbed_object.angular_velocity = Vector3.ZERO
# --- DÉTECTION OBJETS (Area3D avec signals) ---

func _on_pickup_area_body_entered(body: Node3D) -> void:
	if body is RigidBody3D:
		area_overlapping = body

func _on_pickup_area_body_exited(body: Node3D) -> void:
	if area_overlapping == body:
		area_overlapping = null

# --- AUTRES MÉTHODES DU PLAYER (inchangées) ---
func update_state_vars() -> void:
	state_vars["sprinting"] = Input.is_action_pressed("sprint") and not state_vars["crouching"] and not state_vars["aiming"]
	state_vars["crouching"] = Input.is_action_pressed("crouch")
	state_vars["aiming"] = Input.is_action_pressed("aim")
	state_vars["jumping"] = not is_on_floor()

func handle_movement(delta: float) -> void:
	if not mouse_captured:
		return

	var right = pivot.transform.basis.x
	var forward = right.rotated(Vector3.UP, deg_to_rad(90))
	target_direction = Vector3.ZERO

	if Input.is_action_pressed("move_forward"):
		target_direction -= forward
	if Input.is_action_pressed("move_backward"):
		target_direction += forward
	if Input.is_action_pressed("move_right"):
		target_direction -= right
	if Input.is_action_pressed("move_left"):
		target_direction += right

	if target_direction.length() > 1:
		target_direction = target_direction.normalized()

	direction = direction.lerp(target_direction, TRANSITION_SPEED * delta)

	var current_speed = speed
	if state_vars["sprinting"]:
		current_speed *= sprint_speed_multiplier
	elif state_vars["crouching"]:
		current_speed *= crouch_speed_multiplier

	velocity.x = direction.x * current_speed
	velocity.z = direction.z * current_speed

	if direction != Vector3.ZERO and not state_vars["aiming"]:
		var target_angle = atan2(-direction.x, -direction.z)
		rotation.y = lerp_angle(rotation.y, target_angle, TRANSITION_SPEED * delta)

	if Input.is_action_just_pressed("jump") and jumps_remaining > 0:
		velocity.y = jump_height
		jumps_remaining -= 1
		state_vars["jumping"] = true

	if is_on_floor():
		jumps_remaining = jump_count
		state_vars["jumping"] = false

	velocity.y -= 9.8 * gravity_multiplier * delta

func interact() -> void:
	if Input.is_action_just_pressed("attack"):
		if area_overlapping != null:
			if area_overlapping.get_parent().has_method("toggle"):
				area_overlapping.get_parent().toggle()

func toggle_mouse_capture() -> void:
	mouse_captured = not mouse_captured
	if mouse_captured:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func toggle_weapon() -> void:
	current_weapon = "rifle" if current_weapon == "pistol" else "pistol"

func get_type_perso() -> String:
	return "player"

func handle_aiming() -> void:
	if state_vars["aiming"]:
		var cam_forward = pivot.global_transform.basis.z
		cam_forward.y = 0
		cam_forward = cam_forward.normalized()
		look_at(global_position + cam_forward, Vector3.UP)

func get_horizontal_velocity() -> float:
	return Vector3(velocity.x, 0, velocity.z).length()
	
func is_moving():
	if Input.is_action_pressed("move_forward") :
		return true
	elif Input.is_action_pressed("move_backward") :
		return true
	elif Input.is_action_pressed("move_left") :
		return true
	elif Input.is_action_pressed("move_right"):
		return true
	else :
		return false
