extends Node

var tetris_grid : TetrisGrid
var rows : int
var columns : int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tetris_grid = get_parent()
	rows = tetris_grid.num_rows
	columns = tetris_grid.num_columns


func check_lines() -> bool:
	tetris_grid.cleaning_up = true
	for i in range(rows - 1, -1, -1):
		var current_row = tetris_grid.tile_rows[i]
		if is_line_full(current_row):
			tetris_grid.stall(1)
			clear_line(i)
			await get_tree().create_timer(0.25).timeout
			shift_rows_down(i)
			await get_tree().create_timer(0.25).timeout
			var more = await check_lines()
			if more:
				tetris_grid.spawn_piece()
			return true
	tetris_grid.cleaning_up = false
	return false


func clear_line(row_index: int) -> void:
	for tile in tetris_grid.tile_rows[row_index]:
		tile.has_block = false
		tile.texture = tile.original_texture


func shift_rows_down(cleared_row_index: int) -> void:
	for i in range(cleared_row_index - 1, -1, -1):
		for j in range(columns):
			var tile_above : GridTile = tetris_grid.tile_rows[i][j]
			var tile_below : GridTile = tetris_grid.tile_rows[i+1][j]
			
			if tile_above.has_block:
				tile_below.has_block = true
				tile_below.texture = tile_above.texture
				
				tile_above.has_block = false
				tile_above.texture = tile_above.original_texture


func is_line_full(line : Array):
	for tile in line:
		if !tile.has_block:
			return false
	return true
