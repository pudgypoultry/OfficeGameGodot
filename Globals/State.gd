extends Node
class_name State

## Abstract class for a general-use state
var state_manager : StateManager
var actor_reference : CharacterBody3D


func _ready():
	state_manager = get_parent()
	# print(state_manager.name)
	actor_reference = state_manager.actor_reference
	# print(actor_reference.name)


func enter_state(last_state : State):
	pass


func leave_state(next_state : State):
	pass


@warning_ignore("unused_parameter")
func state_process(delta):
	pass


@warning_ignore("unused_parameter")
func state_physics_process(delta):
	pass


@warning_ignore("unused_parameter")
func state_unhandled_input(event):
	pass


func change_state(state_name : String):
	state_manager.change_state(state_manager.states[state_name])
