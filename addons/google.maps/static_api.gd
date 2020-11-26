extends Node
class_name GoogleMapsStaticAPI
"""Implementation of the Static API from Google Maps
"""
const sizes = [ 
	"1024x1024",
	"512x512",
	"256x256",
	"128x128"
]

enum SIZES{
	x1024,
	x512
	x256
	x128
}

signal texture_updated(texture)
signal center_loaded()

#Settings
export(String) var API_KEY : String = ""
export(Color, RGB) var line_color : Color = 0x0000ff
export(SIZES) var size_id : int = SIZES.x512
export(int, 1, 8) var road_width : int = 5
export(bool) var override_center : bool = false
export(String) var map_center_override : String = ""

#Node variables
onready var http = HTTPRequest.new()
onready var dircs = HTTPRequest.new()
onready var JsLoc = JsLocations.new()
onready var texture_output = ImageTexture.new()

#Drawing variables
var zoom : int = 15
var map_center : String = "Centro+Historico,Puebla,PUE"
var route_points : Array = []
var polyline_encoded : String = ""

func _ready():
	add_child(http)
	add_child(dircs)
	add_child(JsLoc)
	http.connect("request_completed", self, "_image_request_completed")
	dircs.connect("request_completed", self, "_directions_request_completed")
	JsLoc.connect("location_found", self, "_on_location_found")
	if not override_center:
		JsLoc.get_user_position()


func zoomin():
	if zoom < 20:
		zoom += 1
		make_request()

func zoomout():
	if zoom > 1:
		zoom -= 1
		make_request()

func name_to_API(point_name : String) -> String:
	point_name = point_name.replace(" ", "+")
	point_name = point_name.trim_suffix("+")
	return point_name

func _image_request_completed(result, response_code, headers, body):
	var image = Image.new()
	var error = image.load_png_from_buffer(body)
	if error != OK:
		push_error("Couldn't load the image.")
		return
	texture_output.create_from_image(image)
	emit_signal("texture_updated", texture_output)
	
	
func _directions_request_completed(result, response_code, headers, body : PoolByteArray):
	var json : Dictionary = JSON.parse(body.get_string_from_utf8()).result
	print(json)
	var ret = json.get("routes")[0].get("overview_polyline").get("points")
	polyline_encoded = "enc:"+ret

func make_request():
	var base : String = "https://maps.googleapis.com/maps/api/staticmap?center="+map_center+"&zoom="+str(zoom)+"&size="+sizes[size_id]+"&scale=2"
	base = base + "&path=color:0x"+line_color.to_html(false)+"|weight:"+str(road_width)+"|"
	print(line_color.to_html(false))
	
	if polyline_encoded.begins_with("enc:"):
		base = base + polyline_encoded
	
	elif route_points.size() > 0:
		for point in route_points:
			base = base + name_to_API(point) + "|"
		base = base.trim_suffix("|")
		# Perform the HTTP request. The URL below returns a PNG image as of writing.
	
	var error = http.request(base+"&key="+ API_KEY)
	if error != OK:
		push_error("An error occurred in the HTTP request.")

func request_directions():
	var base = "https://maps.googleapis.com/maps/api/directions/json?origin="
	base = base + name_to_API(route_points.front())
	base = base + "&destination=" + name_to_API(route_points.back())
	if route_points.size() > 2:
		base = base + "&waypoints="
		for point_id in range(1, route_points.size()-1):
			base = base + name_to_API(route_points[point_id]) + "|"
		base = base.trim_suffix("|")
	base = base + "&mode=driving&key=" + API_KEY
	var error = dircs.request(base)
	if error != OK:
		push_error("An error occurred in the HTTP request.")

func _on_location_found(where : Vector2):
	map_center = str(where.x)+","+str(where.y)
	make_request()
	emit_signal("center_loaded")


