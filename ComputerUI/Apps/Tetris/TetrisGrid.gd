extends GridContainer
class_name TetrisGrid

@onready var line_checker = $LineChecker

@export var num_columns : int = 10
@export var num_rows : int = 20
@export var tile_object : PackedScene
@export var active_block_texture : Texture2D # Assign a solid color texture in the inspector
@export var valid_blocks : Array[Array]
@export var texture_dict : Dictionary

var used_blocks : Array[Array] = []
var tiles : Array = []
var tile_rows : Array = []


# New variables for piece management
var active_piece_coords : Array = []
var fall_timer : float = 0.0
var fall_interval : float = 0.5 # Seconds before piece automatically falls 1 tile
var is_active : bool = true
var falling_piece : bool = false
var cleaning_up : bool = false
var window_has_focus: bool = true


func _ready() -> void:
	setup()
	spawn_piece()


# Generates the grid and links the tiles.
func setup() -> void:
	for i in range(num_rows):
		var current_row = []
		var new_tile
		for j in range(num_columns):
			new_tile = tile_object.instantiate()
			add_child(new_tile)
			tiles.append(new_tile)
			current_row.append(new_tile)
		tile_rows.append(current_row)
		
	for i in range(len(tiles)):
		tiles[i].prepare(self, i)


func set_focus(focused: bool) -> void:
	window_has_focus = focused


# Spawns a 2x2 'O' piece at the top middle of the grid to test the system.
func spawn_piece() -> void:
	if !falling_piece:
		falling_piece = true
		var start_x = num_columns / 2 - 1
		valid_blocks.shuffle()
		var block = valid_blocks.pop_front()
		active_block_texture = texture_dict[block]
		used_blocks.append(block.duplicate(true))
		for vec in block:
			active_piece_coords.append(Vector2i(vec.x + start_x, vec.y))
		# print(active_piece_coords)
		if len(valid_blocks) == 0:
			valid_blocks = used_blocks.duplicate(true)
			used_blocks = []
		
		if not is_valid_position(active_piece_coords):
			print_debug("Game Over condition reached.")
			set_process(false)
			return
			
		render_active_piece()


# Handles automatic falling (gravity) and captures player movement input.
func _process(delta: float) -> void:
	if is_active && !cleaning_up && window_has_focus:
		fall_timer += delta
		if fall_timer >= fall_interval:
			fall_timer = 0.0
			move_piece(Vector2i(0, 1)) # Try moving down
		if Input.is_action_just_pressed("move_left"):
			move_piece(Vector2i(-1, 0))
		elif Input.is_action_just_pressed("move_right"):
			move_piece(Vector2i(1, 0))
		elif Input.is_action_pressed("move_backward"): # Used as drop/down key
			move_piece(Vector2i(0, 1))
		elif Input.is_action_just_pressed("confirm_action"):
			rotate_piece()


# Calculates intended target coordinates, tests them, and updates visuals if valid.
func move_piece(direction: Vector2i) -> void:
	if active_piece_coords.is_empty(): return
	
	var new_coords : Array[Vector2i] = []
	for coord in active_piece_coords:
		new_coords.append(coord + direction)
		
	if is_valid_position(new_coords):
		clear_active_piece_visuals()
		active_piece_coords = new_coords
		render_active_piece()
	elif direction == Vector2i(0, 1):
		lock_piece()


func is_valid_position(vecs) -> bool:
	for vec in vecs:
		if vec.x < 0 or vec.x >= num_columns or vec.y < 0 or vec.y >= num_rows:
			return false
		var tile = tile_rows[vec.y][vec.x]
		if tile.has_block:
			return false
	return true


func clear_active_piece_visuals() -> void:
	for vec in active_piece_coords:
		var tile = tile_rows[vec.y][vec.x]
		tile.texture = tile.original_texture


func render_active_piece() -> void:
	for vec in active_piece_coords:
		var tile = tile_rows[vec.y][vec.x]
		if active_block_texture:
			tile.texture = active_block_texture
		else:
			# Fallback if no texture is assigned in inspector
			tile.texture = load("res://icon.svg") 


func lock_piece() -> void:
	for vec in active_piece_coords:
		var tile = tile_rows[vec.y][vec.x]
		tile.has_block = true
	active_piece_coords.clear()
	line_checker.check_lines()
	await stall(0.2)
	falling_piece = false
	spawn_piece()


func stall(time: float) -> void:
	is_active = false
	await get_tree().create_timer(time).timeout
	is_active = true


func rotate_piece() -> void:
	if active_piece_coords.is_empty(): return
	
	# Designate the second block in the array as the center of rotation.
	# NOTE: Ensure your valid_blocks arrays are structured so the "center" block is at index 1.
	var pivot = active_piece_coords[1] 
	var rotated_coords : Array[Vector2i] = []
	
	for coord in active_piece_coords:
		var local_coord = coord - pivot
		
		var rotated_local = Vector2i(-local_coord.y, local_coord.x)
		
		var rotated_global = rotated_local + pivot
		rotated_coords.append(rotated_global)
	
	# Check if the primary rotation is valid
	if is_valid_position(rotated_coords):
		apply_rotation(rotated_coords)
	else:
		# Wall Kick: Try shifting left 1 space
		var shifted_left = shift_coords(rotated_coords, Vector2i(-1, 0))
		if is_valid_position(shifted_left):
			apply_rotation(shifted_left)
			return
		
		# Wall Kick: Try shifting right 1 space
		var shifted_right = shift_coords(rotated_coords, Vector2i(1, 0))
		if is_valid_position(shifted_right):
			apply_rotation(shifted_right)
			return
			
		# Wall Kick: Try shifting up 1 space (useful for floor kicks)
		var shifted_up = shift_coords(rotated_coords, Vector2i(0, -1))
		if is_valid_position(shifted_up):
			apply_rotation(shifted_up)
			return


func apply_rotation(new_coords: Array[Vector2i]) -> void:
	clear_active_piece_visuals()
	active_piece_coords = new_coords
	render_active_piece()


func shift_coords(coords: Array[Vector2i], offset: Vector2i) -> Array[Vector2i]:
	var shifted : Array[Vector2i] = []
	for c in coords:
		shifted.append(c + offset)
	return shifted
