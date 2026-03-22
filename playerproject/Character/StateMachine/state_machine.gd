extends Node
class_name StateMachine

@onready var player: Player = $".."
@onready var anim_tree: AnimationTree = $"AuxScene/AnimationTree"

var current_state: Node = null
var states := {}

# Ces noms DOIVENT correspondre exactement aux noms des noeuds dans l'AnimationTree
var blends_top := [
	"Crouch_top",
	"Crouch_walk_top",
	"Idle_top",
	"Jump_top",
	"Pistol_aiming top",
	"Riffle_aiming top",
	"Running_top",
	"Sprint_top"
]
var blends_bott := [
	"Crouch_bott",
	"Crouch_walk_bott",
	"Idle_bott",
	"Jump_bott_2",
	"Pistol_aiming_bott",
	"Riffle_aiming_bott",
	"Running_bott",
	"Sprint_bott"
]

var blend_values_top := {}
var blend_values_bott := {}
var target_top := "Idle_top"
var target_bott := "Idle_bott"

# Vitesse de blend par défaut. Peut être surchargée par set_blends().
@export var blend_speed: float = 8.0
var _current_blend_speed: float = 8.0

# Seuil de vélocité pour considérer le joueur "à l'arrêt"
const NO_VELOCITY_THRESHOLD: float = 0.3

func _ready() -> void:
	if not anim_tree:
		push_error("AnimationTree introuvable au chemin: 'AuxScene/AnimationTree'")
		return
	anim_tree.active = true

	for anim_name in blends_top:
		blend_values_top[anim_name] = 0.0
	for anim_name in blends_bott:
		blend_values_bott[anim_name] = 0.0

	for child in get_children():
		if child.has_method("enter") and child.has_method("update") and child.has_method("exit"):
			states[child.name] = child
			child.machine = self
			child.player = player
	switch_state("IdleState")

func _process(delta: float) -> void:
	_lerp_blends(delta)
	if current_state:
		current_state.update(delta)

func _lerp_blends(delta: float) -> void:
	var t = clamp(_current_blend_speed * delta, 0.0, 1.0)
	for anim_name in blends_top:
		var target := 1.0 if anim_name == target_top else 0.0
		blend_values_top[anim_name] = lerpf(blend_values_top[anim_name], target, t)
		anim_tree.set("parameters/%s/blend" % anim_name, blend_values_top[anim_name])
	for anim_name in blends_bott:
		var target := 1.0 if anim_name == target_bott else 0.0
		blend_values_bott[anim_name] = lerpf(blend_values_bott[anim_name], target, t)
		anim_tree.set("parameters/%s/blend" % anim_name, blend_values_bott[anim_name])

func switch_state(state_name: String) -> void:
	if current_state and current_state.name == state_name:
		return
	if current_state:
		current_state.exit()
	if states.has(state_name):
		current_state = states[state_name]
		current_state.enter()
	else:
		push_warning("Aucun state nommé '%s'" % state_name)

# Définit les animations cibles pour le blend. Utilise les noms EXACTS des noeuds AnimationTree.
# speed_override : si > 0, utilise cette vitesse au lieu du blend_speed par défaut.
func set_blends(top_anim: String, bott_anim: String, speed_override: float = -1.0) -> void:
	if not blend_values_top.has(top_anim):
		push_warning("Blend top inconnu: '%s'. Noms valides: %s" % [top_anim, str(blends_top)])
		return
	if not blend_values_bott.has(bott_anim):
		push_warning("Blend bott inconnu: '%s'. Noms valides: %s" % [bott_anim, str(blends_bott)])
		return
	target_top = top_anim
	target_bott = bott_anim
	_current_blend_speed = speed_override if speed_override > 0.0 else blend_speed

# Snap immédiat vers une animation (utile pour l'atterrissage, la mort, etc.)
func snap_to_blends(top_anim: String, bott_anim: String) -> void:
	if not blend_values_top.has(top_anim) or not blend_values_bott.has(bott_anim):
		push_warning("snap_to_blends: noms invalides ('%s', '%s')" % [top_anim, bott_anim])
		return
	for anim_name in blends_top:
		blend_values_top[anim_name] = 1.0 if anim_name == top_anim else 0.0
	for anim_name in blends_bott:
		blend_values_bott[anim_name] = 1.0 if anim_name == bott_anim else 0.0
	target_top = top_anim
	target_bott = bott_anim
