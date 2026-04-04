extends WebPage

func build_page() -> void:
	print("Hello I'm the test page")
	page_url = "office.net/home"
	page_title = "Welcome"
	add_heading("Welcome to Office.net")
	add_separator()
	add_paragraph("Your one stop shop for all office related needs.")
	add_separator()
	add_paragraph("Check out our latest products:")
	add_spacer(16)
	#add_image(preload("res://ComputerUI/SomeBanner.png"))
