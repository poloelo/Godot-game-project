extends Node
class_name StateMachine

@onready var player: Player = $".."
@onready var anim_tree: AnimationTree = $"AuxScene/AnimationTree"
# Le playback est le controller natif de l'AnimationStateMachine dans Godot 4.
# Les transitions et leur durée de cross-fade se configurent dans l'éditeur AnimationTree,
# pas dans le code — c'est ça qui donne des transitions fluides sans lerp manuel.
@onready var anim_playback: AnimationNodeStateMachinePlayback = anim_tree["parameters/playback"]

var current_state: Node = null
var states := {}

func _ready() -> void:
	anim_tree.active = true
	for child in get_children():
		if child.has_method("enter") and child.has_method("update") and child.has_method("exit"):
			states[child.name] = child
			child.machine = self
			child.player = player
	switch_state("IdleState")

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func switch_state(state_name: String) -> void:
	if current_state and current_state.name == state_name:
		return
	if current_state:
		current_state.exit()
	if states.has(state_name):
		current_state = states[state_name]
		current_state.enter()
	else:
		push_warning("State introuvable: '%s'" % state_name)

# Déclenche une transition dans l'AnimationStateMachine.
# Le cross-fade est défini par transition dans l'éditeur AnimationTree.
# Noms à faire correspondre aux noeuds de ton AnimationStateMachine dans l'éditeur.
func play_anim(anim_name: String) -> void:
	anim_playback.travel(anim_name)
