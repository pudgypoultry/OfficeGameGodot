extends Node

var player : CharacterBody3D
var bosses : Array[Node3D]
var tasks : Array[Node3D]

var is_active : bool = false
var game_timer : float = 0.0


func _process(delta: float) -> void:
	if is_active:
		game_timer += delta


func reset() -> void:
	is_active = false
	game_timer = 0.0
