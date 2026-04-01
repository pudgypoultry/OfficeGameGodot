class_name ComputerWindow
extends Panel

signal window_closed(window)
signal window_focused(window)
signal window_minimized(window)
signal window_restored(window)

@export var title: String = "Untitled" : set = set_title
@export var app_icon: Texture2D : set = set_icon
@export var resizable: bool = true
@export var min_size: Vector2 = Vector2(200, 150)

@onready var layout : VBoxContainer = $Layout
@onready var title_label: Label = $Layout/TitleBar/OptionButtons/WindowName
@onready var app_icon_rect: TextureRect = $Layout/TitleBar/OptionButtons/Icon
@onready var title_bar: NinePatchRect = $Layout/TitleBar/TitleBarBackground
@onready var minimize_btn: Button = $Layout/TitleBar/OptionButtons/WindowButtons/Minimize
@onready var maximize_btn: Button = $Layout/TitleBar/OptionButtons/WindowButtons/Maximize
@onready var close_btn: Button = $Layout/TitleBar/OptionButtons/WindowButtons/Close
@onready var content_area: MarginContainer = $Layout/Content

const RESIZE_MARGIN: int = 6
const CONTENT_PADDING: Vector2 = Vector2(0.01, 0.01)

var _dragging: bool = false
var _drag_offset: Vector2 = Vector2.ZERO
var _maximized: bool = false
var _pre_max_rect: Rect2 = Rect2()
var _resize_dir: Vector2 = Vector2.ZERO
var _resizing: bool = false
static var _active_drag: ComputerWindow = null


func _ready() -> void:
	set_title(title)
	set_icon(app_icon)
	close_btn.pressed.connect(_on_close)
	minimize_btn.pressed.connect(_on_minimize)
	maximize_btn.pressed.connect(_on_maximize)
	gui_input.connect(_on_panel_input)
	mouse_filter = Control.MOUSE_FILTER_STOP
	await get_tree().process_frame
	await get_tree().process_frame
	_fit_to_content()


func _process(_delta: float) -> void:
	if _dragging and not _maximized:
		position = get_parent().get_local_mouse_position() + _drag_offset
		_clamp_to_parent()


func _is_top_window() -> bool:
	var parent = get_parent()
	if not parent: return false
	return parent.get_child(parent.get_child_count() - 1) == self


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed:
			if _active_drag == self:
				_active_drag = null
			_dragging = false
			_resizing = false
		elif _is_on_titlebar(event.global_position):
			if _active_drag != null:
				return
			_bring_to_front()
			if event.double_click:
				_on_maximize()
				return
			_active_drag = self
			_dragging = true
			_resizing = false
			_resize_dir = Vector2.ZERO
			_drag_offset = global_position - get_global_mouse_position()
	if event is InputEventMouseMotion:
		if _dragging and not _maximized:
			global_position = get_global_mouse_position() + _drag_offset
			_clamp_to_parent()
		elif _resizing:
			_do_resize(event.relative)


func _is_on_titlebar(global_mouse: Vector2) -> bool:
	return title_bar.get_global_rect().has_point(global_mouse)


func set_title(new_title: String) -> void:
	title = new_title
	if is_node_ready():
		title_label.text = new_title


func set_icon(texture: Texture2D) -> void:
	app_icon = texture
	if is_node_ready():
		app_icon_rect.texture = texture


func load_content(scene: PackedScene) -> void:
	for child in content_area.get_children():
		child.queue_free()
	var node = scene.instantiate()
	content_area.add_child(node)
	await get_tree().process_frame
	_fit_to_content()
	window_focused.connect(_on_focused)


func _on_focused(win: ComputerWindow) -> void:
	var content = get_content()
	if content.has_method("set_focus"):
		content.set_focus(true)


func _fit_to_content() -> void:
	var required = layout.get_combined_minimum_size()
	size = size.max(required + CONTENT_PADDING)
	layout.size = size


func get_content() -> Control:
	var children = content_area.get_children()
	return children[0] if children.size() > 0 else null


func _on_panel_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_bring_to_front()
		_check_resize_start(event)


func _bring_to_front() -> void:
	var parent = get_parent()
	if parent:
		parent.move_child(self, parent.get_child_count() - 1)
	emit_signal("window_focused", self)


func _check_resize_start(event: InputEventMouseButton) -> void:
	if not resizable or _maximized:
		return
	if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_resize_dir = _get_resize_direction(event.position)
		_resizing = _resize_dir != Vector2.ZERO


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		if is_node_ready():
			layout.size = size


func _get_resize_direction(mouse_pos: Vector2) -> Vector2:
	var dir = Vector2.ZERO
	if mouse_pos.x < RESIZE_MARGIN: dir.x = -1
	elif mouse_pos.x > size.x - RESIZE_MARGIN: dir.x = 1
	if mouse_pos.y < RESIZE_MARGIN: dir.y = -1
	elif mouse_pos.y > size.y - RESIZE_MARGIN: dir.y = 1
	return dir


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


func _on_minimize() -> void:
	visible = false
	emit_signal("window_minimized", self)


func restore() -> void:
	visible = true
	_bring_to_front()
	emit_signal("window_restored", self)


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
	var bounds = get_viewport_rect()
	global_position.x = clamp(global_position.x, bounds.position.x, bounds.position.x + bounds.size.x - size.x)
	global_position.y = clamp(global_position.y, bounds.position.y, bounds.position.y + bounds.size.y - size.y)
