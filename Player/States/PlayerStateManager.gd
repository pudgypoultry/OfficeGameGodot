extends StateManager

@onready var walk_state : State = $BaseMovement


func _ready() -> void:
	super()


func _process(delta : float) -> void:
	super(delta)
