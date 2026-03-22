extends Node
class_name StateMachine

@onready var player = $".."
@onready var anim_tree = $"AuxScene/AnimationTree"

var current_state: Node = null
var states := {}

var blends_top := [
	"Crouch Top",
	"Crouch Walk Top",
	"Idle Top",
	"Jump Top",
	"Pistol Aiming Top",
	"Riffle Aiming Top",
	"Running Top",
	"Sprint Top"
]
var blends_bott := [
	"Crouch Bott",
	"Crouch Walk Bott",
	"Idle Bott",
	"Jump Bott 2",
	"Pistol Aiming Bott",
	"Riffle Aiming Bott",
	"Running Bott",
	"Sprint Bott"
]

var blend_values_top := {}
var blend_values_bott := {}
var target_top := "Idle Top"
var target_bott := "Idle Bott"
@export var blend_speed: float = 8.0

func _ready():
	if not anim_tree:
		push_error("AnimationTree introuvable au chemin: 'AuxScene/AnimationTree'")
	if anim_tree and not anim_tree.active:
		anim_tree.active = true

	for name in blends_top:
		blend_values_top[name] = 0.0
	for name in blends_bott:
		blend_values_bott[name] = 0.0

	for child in get_children():
		if child.has_method("enter") and child.has_method("update") and child.has_method("exit"):
			states[child.name] = child
			child.machine = self
	switch_state("IdleState")

func _process(delta):
	for name in blends_top:
		var target = 1.0 if name == target_top else 0.0
		blend_values_top[name] = lerp(blend_values_top[name], target, clamp(blend_speed * delta, 0, 1))
		anim_tree.set("parameters/%s/blend" % name, blend_values_top[name])
	for name in blends_bott:
		var target = 1.0 if name == target_bott else 0.0
		blend_values_bott[name] = lerp(blend_values_bott[name], target, clamp(blend_speed * delta, 0, 1))
		anim_tree.set("parameters/%s/blend" % name, blend_values_bott[name])
	if current_state:
		current_state.update(delta)

func switch_state(state_name: String):
	if current_state and current_state.name == state_name:
		return
	if current_state:
		current_state.exit()
	if states.has(state_name):
		current_state = states[state_name]
		current_state.enter()
	else:
		push_warning("Aucun state nommé '%s'" % state_name)

func set_blends(top_anim: String, bott_anim: String):
	if not blend_values_top.has(top_anim):
		push_warning("Blend top inconnu: %s" % top_anim)
	else:
		target_top = top_anim
	if not blend_values_bott.has(bott_anim):
		push_warning("Blend bott inconnu: %s" % bott_anim)
	else:
		target_bott = bott_anim
