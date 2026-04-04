class_name WebPage
extends VBoxContainer

signal link_clicked(page: PackedScene)

const HEADING_FONT_SIZE : int = 20
const BODY_FONT_SIZE : int = 12
const LINK_COLOR : Color = Color(0, 0, 0.8, 1)

var page_title = ""
var page_url = ""

func _ready() -> void:
	size_flags_horizontal = Control.SIZE_FILL
	size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	custom_minimum_size.x = 300
	call_deferred("build_page")


func build_page() -> void:
	pass


func add_heading(text: String) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", HEADING_FONT_SIZE)
	lbl.size_flags_horizontal = Control.SIZE_FILL
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(lbl)
	return lbl


func add_paragraph(text: String) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", BODY_FONT_SIZE)
	lbl.size_flags_horizontal = Control.SIZE_FILL
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(lbl)
	return lbl


func add_image(texture: Texture2D, max_width: int = 300) -> TextureRect:
	var img := TextureRect.new()
	img.texture = texture
	img.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	img.custom_minimum_size.x = max_width
	img.size_flags_horizontal = Control.SIZE_FILL
	add_child(img)
	return img


func add_link(text: String, page: PackedScene) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.flat = true
	btn.focus_mode = Control.FOCUS_NONE
	btn.add_theme_color_override("font_color", LINK_COLOR)
	btn.add_theme_color_override("font_hover_color", LINK_COLOR)
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.pressed.connect(func(): link_clicked.emit(page))
	add_child(btn)
	return btn


func add_separator() -> HSeparator:
	var sep := HSeparator.new()
	sep.size_flags_horizontal = Control.SIZE_FILL
	add_child(sep)
	return sep


func add_vertical_space(height: int = 8) -> Control:
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, height)
	add_child(spacer)
	return spacer
