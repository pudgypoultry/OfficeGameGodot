class_name ComputerDesktop
extends CanvasLayer

@onready var window_layer : Control = $Desktop/WindowLayer
@onready var app_buttons : HBoxContainer = $Desktop/Taskbar/MarginContainer/TaskbarLayout/AppButtons
@onready var start_button : Button = $Desktop/Taskbar/MarginContainer/TaskbarLayout/StartButton
@onready var clock_label : Label = $Desktop/Taskbar/MarginContainer/TaskbarLayout/SystemTray/Clock
@onready var desktop_icons : VBoxContainer = $Desktop/DesktopIcons

@export var window_scene : PackedScene
@export var taskbar_button_scene : PackedScene

var _clock_timer: float = 0.0
var app_scene = preload("res://Tetris/TetrisMinigame.tscn")


func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	_update_clock()
	await get_tree().create_timer(0.75).timeout
	open_window(app_scene, "Spreaddddsheeeetttssssss")
	await get_tree().create_timer(0.75).timeout
	open_window(app_scene, "Sheeeetttssssss")
	await get_tree().create_timer(0.75).timeout
	open_window(app_scene, "Spread")
	


func _process(delta: float) -> void:
	_clock_timer += delta
	if _clock_timer >= 1.0:
		_clock_timer = 0.0
		_update_clock()


func _update_clock() -> void:
	var t = Time.get_time_dict_from_system()
	clock_label.text = "%02d:%02d" % [t.hour, t.minute]


# --- Window Management ---

func open_window(app: PackedScene, title: String, icon: Texture2D = null) -> ComputerWindow:
	var win: ComputerWindow = window_scene.instantiate()
	win.title = title
	win.app_icon = icon
	window_layer.add_child(win)
	win.position = Vector2(40, 40)
	win.load_content(app)
	win.window_minimized.connect(_on_window_minimized)
	win.window_restored.connect(_on_window_restored)
	win.window_closed.connect(_on_window_closed)
	_add_taskbar_button(win)
	return win


func _add_taskbar_button(win: ComputerWindow) -> void:
	var btn := taskbar_button_scene.instantiate()
	btn.text = win.title
	btn.name = "TaskBtn_" + str(win.get_instance_id())
	btn.pressed.connect(_on_taskbar_btn_pressed.bind(win))
	app_buttons.add_child(btn)


func _get_taskbar_button(win: ComputerWindow) -> Button:
	var target_name = "TaskBtn_" + str(win.get_instance_id())
	for child in app_buttons.get_children():
		if child.name == target_name:
			return child as Button
	return null


func _on_taskbar_btn_pressed(win: ComputerWindow) -> void:
	if win.visible:
		win._on_minimize()
	else:
		win.restore()


func _on_window_minimized(win: ComputerWindow) -> void:
	var btn = _get_taskbar_button(win)
	if btn:
		btn.button_pressed = false


func _on_window_restored(win: ComputerWindow) -> void:
	var btn = _get_taskbar_button(win)
	if btn:
		btn.button_pressed = true


func _on_window_closed(win: ComputerWindow) -> void:
	print("window closed: ", win.title)
	var btn = _get_taskbar_button(win)
	print("button found: ", btn)
	if btn:
		btn.queue_free()


# --- Desktop Icons ---

func add_desktop_icon(label: String, icon: Texture2D, app: PackedScene) -> void:
	var btn := Button.new()
	btn.text = label
	btn.icon = icon
	btn.custom_minimum_size = Vector2(64, 64)
	btn.expand_icon = true
	btn.focus_mode = Control.FOCUS_NONE
	btn.pressed.connect(open_window.bind(app, label, icon))
	desktop_icons.add_child(btn)


# --- Start Menu (stub) ---

func _on_start_pressed() -> void:
	pass  # hook up a start menu popup here later
