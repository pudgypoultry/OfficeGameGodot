class_name Win95Window
extends Panel

signal window_closed(window)
signal window_focused(window)

@export var title: String = "Untitled" : set = set_title
@export var app_icon: Texture2D : set = set_icon
@export var resizable: bool = true
@export var min_size: Vector2 = Vector2(200, 150)

@onready var title_label: Label = $Layout/TitleBar/OptionButtons/WindowName
@onready var app_icon_rect: TextureRect = $Layout/TitleBar/OptionButtons/Icon
@onready var title_bar: NinePatchRect = $Layout/TitleBar/TitleBarBackground
@onready var minimize_btn: Button = $Layout/TitleBar/OptionButtons/WindowButtons/Minimize
@onready var maximize_btn: Button = $Layout/TitleBar/OptionButtons/WindowButtons/Maximize
@onready var close_btn: Button = $Layout/TitleBar/OptionButtons/WindowButtons/Close
@onready var content_area: MarginContainer = $Layout/Content

const RESIZE_MARGIN: int = 6

var _dragging: bool = false
var _drag_offset: Vector2 = Vector2.ZERO
var _maximized: bool = false
var _pre_max_rect: Rect2 = Rect2()
var _resize_dir: Vector2 = Vector2.ZERO
var _resizing: bool = false


func _ready() -> void:
	set_title(title)
	set_icon(app_icon)
	close_btn.pressed.connect(_on_close)
	minimize_btn.pressed.connect(_on_minimize)
	maximize_btn.pressed.connect(_on_maximize)
	title_bar.gui_input.connect(_on_titlebar_input)
	gui_input.connect(_on_panel_input)
	mouse_filter = Control.MOUSE_FILTER_STOP


func set_title(new_title: String) -> void:
	title = new_title
	if is_node_ready():
		title_label.text = new_title


func set_icon(texture: Texture2D) -> void:
	app_icon = texture
	if is_node_ready():
		app_icon_rect.texture = texture
		app_icon_rect.visible = texture != null


func load_content(scene: PackedScene) -> void:
	# Clear any existing content
	for child in content_area.get_children():
		child.queue_free()
	var node = scene.instantiate()
	content_area.add_child(node)


func get_content() -> Control:
	var children = content_area.get_children()
	return children[0] if children.size() > 0 else null


# --- Focus ---
func _on_panel_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_bring_to_front()
		_check_resize_start(event)


func _bring_to_front() -> void:
	var parent = get_parent()
	if parent:
		parent.move_child(self, parent.get_child_count() - 1)
	emit_signal("window_focused", self)


# --- Drag ---
func _on_titlebar_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.double_click:
				_on_maximize()
				return
			_dragging = event.pressed
			if _dragging:
				_drag_offset = global_position - get_global_mouse_position()
				_bring_to_front()
	if event is InputEventMouseMotion and _dragging and not _maximized:
		global_position = get_global_mouse_position() + _drag_offset
		_clamp_to_parent()


# --- Resize ---
func _check_resize_start(event: InputEventMouseButton) -> void:
	if not resizable or _maximized:
		return
	if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_resize_dir = _get_resize_direction(event.position)
		_resizing = _resize_dir != Vector2.ZERO


func _get_resize_direction(mouse_pos: Vector2) -> Vector2:
	var dir = Vector2.ZERO
	if mouse_pos.x < RESIZE_MARGIN: dir.x = -1
	elif mouse_pos.x > size.x - RESIZE_MARGIN: dir.x = 1
	if mouse_pos.y < RESIZE_MARGIN: dir.y = -1
	elif mouse_pos.y > size.y - RESIZE_MARGIN: dir.y = 1
	return dir


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not event.pressed:
		_dragging = false
		_resizing = false
	if event is InputEventMouseMotion:
		if _resizing:
			_do_resize(event.relative)


func _do_resize(delta: Vector2) -> void:
	var new_size = size
	var new_pos = position
	if _resize_dir.x == 1: new_size.x += delta.x
	elif _resize_dir.x == -1:
		new_size.x -= delta.x
		new_pos.x += delta.x
	if _resize_dir.y == 1: new_size.y += delta.y
	elif _resize_dir.y == -1:
		new_size.y -= delta.y
		new_pos.y += delta.y
	new_size = new_size.max(min_size)
	size = new_size
	position = new_pos


# --- Minimize / Maximize / Close ---
func _on_minimize() -> void:
	visible = false
	# Taskbar button should re-show it — connect to window_focused or handle externally


func _on_maximize() -> void:
	if _maximized:
		position = _pre_max_rect.position
		size = _pre_max_rect.size
		_maximized = false
	else:
		_pre_max_rect = Rect2(position, size)
		var parent = get_parent()
		if parent:
			position = Vector2.ZERO
			size = parent.size
		_maximized = true


func _on_close() -> void:
	emit_signal("window_closed", self)
	queue_free()


func _clamp_to_parent() -> void:
	var parent = get_parent()
	if not parent: return
	var p_size = parent.size
	position.x = clamp(position.x, 0, p_size.x - size.x)
	position.y = clamp(position.y, 0, p_size.y - size.y)
