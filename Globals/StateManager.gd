extends Node
class_name StateManager

## This script is meant to orchestrate an actor's state and act as a bus 
##  between the actor's states and its signals

@export var current_state : State
@export var states : Dictionary[String,State]
@export var actor_reference : CharacterBody3D
@export var debug : bool = false

signal leaving_state(old_state : State)
signal entering_state(new_state : State)


func _ready() -> void:
	if !actor_reference:
		actor_reference = get_parent()
	if debug:
		print_debug("Current Actor Reference: ", actor_reference.name)
	if current_state:
		current_state.enter_state(null)


func _process(delta: float) -> void:
	current_state.state_process(delta)


func _physics_process(delta: float) -> void:
	current_state.state_physics_process(delta)


func _unhandled_input(event: InputEvent) -> void:
	current_state.state_unhandled_input(event)


func change_state(new_state : State):
	if debug:
		print_debug("Leaving " + current_state.name + " and entering " + new_state.name)
	current_state.leave_state(new_state)
	leaving_state.emit(current_state)
	var old_state = current_state
	current_state = new_state
	current_state.enter_state(old_state)
	entering_state.emit(current_state)
