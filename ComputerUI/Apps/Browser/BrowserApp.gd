class_name BrowserApp
extends VBoxContainer

@onready var back_btn: Button = $Toolbar/MarginContainer/HBoxContainer/Back
@onready var forward_btn: Button = $Toolbar/MarginContainer/HBoxContainer/Forward
@onready var address_bar: LineEdit = $Toolbar/MarginContainer/HBoxContainer/AddressBar
@onready var page_container: ScrollContainer = $PageContainer

@export var home_page: PackedScene

var _back_stack: Array[PackedScene] = []
var _forward_stack: Array[PackedScene] = []
var _current_page: PackedScene = null

func _ready() -> void:
	back_btn.pressed.connect(_on_back)
	forward_btn.pressed.connect(_on_forward)
	address_bar.editable = false
	_update_nav_buttons()
	await get_tree().create_timer(2.0).timeout
	if home_page:
		open_page(home_page)


func open_page(page: PackedScene) -> void:
	if _current_page != null:
		_back_stack.append(_current_page)
	_forward_stack.clear()
	_load_page(page)


func _load_page(page: PackedScene) -> void:
	for child in page_container.get_children():
		child.free()

	var instance: WebPage = page.instantiate()
	page_container.add_child(instance)
	instance.link_clicked.connect(_on_link_clicked)

	_current_page = page
	address_bar.text = instance.page_title
	_update_nav_buttons()
	await get_tree().process_frame
	_fit_window()

func _fit_window() -> void:
	var window = get_parent()
	while window != null:
		if window is ComputerWindow:
			window._fit_to_content()
			return
		window = window.get_parent()


func _on_link_clicked(page: PackedScene) -> void:
	open_page(page)


func _on_back() -> void:
	if _back_stack.is_empty(): return
	_forward_stack.append(_current_page)
	_load_page(_back_stack.pop_back())


func _on_forward() -> void:
	if _forward_stack.is_empty(): return
	_back_stack.append(_current_page)
	_load_page(_forward_stack.pop_back())


func _update_nav_buttons() -> void:
	back_btn.disabled = _back_stack.is_empty()
	forward_btn.disabled = _forward_stack.is_empty()
