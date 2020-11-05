extends PanelContainer

onready var confirm_dialog = $HSplitContainer/TabContainer/Tabs/VBoxContainer/Control/ConfirmationDialog
onready var icon = preload("res://location_icon.png")
func _ready():
	confirm_dialog.connect("request_new_point", self, "create_item")
	$HTTPRequest.connect("request_completed", self, "_http_request_completed")

	# Perform the HTTP request. The URL below returns a PNG image as of writing.
	var error = $HTTPRequest.request("https://maps.googleapis.com/maps/api/staticmap?center=Centro+Historico,Puebla,PUE&zoom=15&size=512x512&key=AIzaSyDQtnZ10PrsZ9mz459NhSxdtqvjVV40G9o")
	if error != OK:
		push_error("An error occurred in the HTTP request.")


func _on_Punto_pressed():
	confirm_dialog.popup_centered()

func create_item(point_info):
	var panel = PanelContainer.new()
	var box = HBoxContainer.new()
	var texx = TextureButton.new()
	var label = Label.new()
	texx.texture_normal = icon
	label.text = point_info.get("direccion")
	panel.add_child(box)
	box.add_child(texx)
	box.add_child(label)
	$HSplitContainer/TabContainer/Tabs/VBoxContainer/ScrollContainer/ItemList.add_child(panel)

func _http_request_completed(result, response_code, headers, body):
	var image = Image.new()
	var error = image.load_png_from_buffer(body)
	if error != OK:
		push_error("Couldn't load the image.")
		return
	var tex = ImageTexture.new()
	tex.create_from_image(image)
	$HSplitContainer/ViewportContainer/TextureRect.texture = tex

