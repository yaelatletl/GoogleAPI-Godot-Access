extends PanelContainer
const API_KEY = "AIzaSyDQtnZ10PrsZ9mz459NhSxdtqvjVV40G9o"
onready var confirm_dialog = $HSplitContainer/TabContainer/Tabs/VBoxContainer/Control/ConfirmationDialog
onready var icon = preload("res://location_icon.png")
onready var http = $HTTPRequest
onready var dircs = $Directions

var points : Array = []
var route : String = ""
func _ready():
	confirm_dialog.connect("request_new_point", self, "create_item")
	http.connect("request_completed", self, "_image_request_completed")
	dircs.connect("request_completed", self, "_directions_request_completed")
	make_request()

func name_to_API(point_name : String):
	point_name = point_name.replace(" ", "+")
	point_name = point_name.trim_suffix("+")
	return point_name

func _on_Punto_pressed():
	confirm_dialog.popup_centered()

func create_item(point_info):
	var panel = PanelContainer.new()
	var box = HBoxContainer.new()
	var texx = TextureButton.new()
	var label = Label.new()
	texx.texture_normal = icon
	label.text = point_info.get("direccion")
	points.append(point_info.get("direccion"))
	panel.add_child(box)
	box.add_child(texx)
	box.add_child(label)
	$HSplitContainer/TabContainer/Tabs/VBoxContainer/ScrollContainer/ItemList.add_child(panel)
	make_request()

func _image_request_completed(result, response_code, headers, body):
	var image = Image.new()
	var error = image.load_png_from_buffer(body)
	if error != OK:
		push_error("Couldn't load the image.")
		return
	var tex = ImageTexture.new()
	tex.create_from_image(image)
	$HSplitContainer/ViewportContainer/TextureRect.texture = tex

func _directions_request_completed(result, response_code, headers, body):
	route = body.get_string_from_utf8()

func make_request():
	var base : String = "https://maps.googleapis.com/maps/api/staticmap?center=Centro+Historico,Puebla,PUE&zoom=15&size=512x512"
	if points.size() > 0:
		base = base + "&path=color:0x0000ff|weight:5|"
		for point in points:
			base = base + name_to_API(point) + "|"
		base = base.trim_suffix("|")
		# Perform the HTTP request. The URL below returns a PNG image as of writing.
	print(base+"&key=AIzaSyDQtnZ10PrsZ9mz459NhSxdtqvjVV40G9o")
	var error = http.request(base+"&key="+ API_KEY)
	if error != OK:
		push_error("An error occurred in the HTTP request.")

func request_directions(from, to):
	var base = "https://maps.googleapis.com/maps/api/directions/json?origin="
	base = base + name_to_API(from)
	base = base + "&destination=" + name_to_API(to)
	base = base + "mode=driving&key=" + API_KEY
	var error = dircs.request(base)
	if error != OK:
		push_error("An error occurred in the HTTP request.")

