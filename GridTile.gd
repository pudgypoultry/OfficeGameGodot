extends TextureRect
class_name GridTile

@export var preview_color : Color
@export var test_texture : Texture2D
@export var debug : bool = false

var tetris_grid = null
var prepared = false
var index : int = 0
var has_block : bool = false
var is_resting : bool = true

var original_texture = texture
var up : GridTile = null
var up_right : GridTile = null
var up_left : GridTile = null
var down : GridTile = null
var down_right : GridTile = null
var down_left : GridTile = null
var left : GridTile = null
var right : GridTile = null


func prepare(parent : TetrisGrid, pos : int) -> void:
	tetris_grid = parent
	index = pos
	if index - 1 >= tetris_grid.num_columns and index % tetris_grid.num_columns != 0:
		up_left = tetris_grid.tiles[index - 1 - tetris_grid.num_columns]
	if index >= tetris_grid.num_columns:
		up = tetris_grid.tiles[index - tetris_grid.num_columns]
	if index + 1 >= tetris_grid.num_columns and (index + 1) % tetris_grid.num_columns != 0:
		up_right = tetris_grid.tiles[index + 1 - tetris_grid.num_columns]
	if index + tetris_grid.num_columns - 1 <= len(tetris_grid.tiles) - 1 and index % tetris_grid.num_columns != 0:
		down_left = tetris_grid.tiles[index + tetris_grid.num_columns - 1]
	if index + tetris_grid.num_columns <= len(tetris_grid.tiles) - 1:
		down = tetris_grid.tiles[index + tetris_grid.num_columns]
	if index + tetris_grid.num_columns + 1 <= len(tetris_grid.tiles) - 1 and (index + 1) % tetris_grid.num_columns != 0:
		down_right = tetris_grid.tiles[index + tetris_grid.num_columns + 1]
	if index % tetris_grid.num_columns != 0:
		left = tetris_grid.tiles[index - 1]
	if (index + 1) % tetris_grid.num_columns != 0 and index != len(tetris_grid.tiles) - 1:
		right = tetris_grid.tiles[index + 1]


func debug_mouse_over():
	if debug:
		texture = test_texture
		if left:
			left.texture = test_texture
		if right:
			right.texture = test_texture
		if up:
			up.texture = test_texture
		if up_left:
			up_left.texture = test_texture
		if up_right:
			up_right.texture = test_texture
		if down:
			down.texture = test_texture
		if down_left:
			down_left.texture = test_texture
		if down_right:
			down_right.texture = test_texture


func debug_mouse_exited():
	if debug:
		texture = original_texture
		if left:
			left.texture = left.original_texture
		if right:
			right.texture = right.original_texture
		if up:
			up.texture = up.original_texture
		if up_left:
			up_left.texture = up_left.original_texture
		if up_right:
			up_right.texture = up_right.original_texture
		if down:
			down.texture = down.original_texture
		if down_left:
			down_left.texture = down_left.original_texture
		if down_right:
			down_right.texture = down_right.original_texture


func debug_lights():
	texture = test_texture
	await get_tree().create_timer(1.0).timeout
	texture = original_texture
