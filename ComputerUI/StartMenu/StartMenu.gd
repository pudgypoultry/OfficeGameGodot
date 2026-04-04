extends Control
class_name StartMenu

@onready var desktop : CanvasLayer = get_parent()
@onready var app_list: VBoxContainer = $Container/Content/AppList
@onready var stylebox_texture : StyleBoxTexture = preload("res://ComputerUI/StartMenu/StartMenuItem.tres")

var _start_menu_open: bool = false


func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	add_start_menu_entry("Spreadsheets", null, preload("res://ComputerUI/Apps/Tetris/TetrisMinigame.tscn"))
	add_start_menu_entry("Browser", null, preload("res://ComputerUI/Apps/Browser/BrowserApp.tscn"))


func _on_start_pressed() -> void:
	_start_menu_open = !_start_menu_open
	visible = _start_menu_open


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if _start_menu_open and not get_global_rect().has_point(event.global_position):
			_close_start_menu()


func _close_start_menu() -> void:
	_start_menu_open = false
	visible = false


func add_start_menu_entry(label: String, icon: Texture2D, app: PackedScene) -> void:
	var btn := Button.new()
	btn.text = label
	btn.icon = icon
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.focus_mode = Control.FOCUS_NONE
	btn.size_flags_horizontal = Control.SIZE_FILL
	btn.custom_minimum_size = Vector2(0, 36)
	btn.add_theme_stylebox_override("normal", stylebox_texture)
	btn.add_theme_stylebox_override("hover", stylebox_texture)
	btn.add_theme_stylebox_override("pressed", stylebox_texture)
	btn.pressed.connect(_on_start_entry_pressed.bind(app, label, icon))
	app_list.add_child(btn)


func _on_start_entry_pressed(app: PackedScene, label: String, icon: Texture2D) -> void:
	_close_start_menu()
	desktop.open_window(app, label, icon)
