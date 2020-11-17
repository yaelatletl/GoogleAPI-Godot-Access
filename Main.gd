extends PanelContainer
const API_KEY = "AIzaSyDQtnZ10PrsZ9mz459NhSxdtqvjVV40G9o"
onready var confirm_dialog = $HSplitContainer/TabContainer/Tabs/VBoxContainer/Control/ConfirmationDialog
onready var icon = preload("res://assets/icon_64.png")
onready var del_icon = preload("res://assets/icon_remove.svg")
onready var static_api = $GoogleStaticAPI
onready var list = $HSplitContainer/TabContainer/Tabs/VBoxContainer/ScrollContainer/ItemList


func _ready():
	static_api.connect("texture_updated", self, "_on_texture_updated")
	static_api.connect("center_loaded", self, "_on_center_loaded")
	confirm_dialog.connect("request_new_point", self, "create_item")
	static_api.make_request()

func name_to_API(point_name : String):
	point_name = point_name.replace(" ", "+")
	point_name = point_name.trim_suffix("+")
	return point_name

func _on_Punto_pressed():
	confirm_dialog.popup_centered()

func create_item(point_info):
	var panel = PanelContainer.new()
	var box = HBoxContainer.new()
	var box2 = VBoxContainer.new()
	var texx = TextureButton.new()
	var del = TextureButton.new()
	var dir_label = Label.new()
	var cli_label = Label.new()
	var cant_label = Label.new()
	texx.texture_normal = icon
	del.texture_normal = del_icon
	del.expand = true
	del.stretch_mode = TextureButton.STRETCH_KEEP_CENTERED
	del.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	del.size_flags_vertical = Control.SIZE_EXPAND_FILL
	dir_label.text = point_info.get("direccion")
	cli_label.text = "Destinatario: " + point_info.get("cliente")
	cant_label.text = "Cantidad: " + str(point_info.get("cantidad"))
	static_api.route_points.append(point_info.get("direccion"))
	panel.add_child(box)
	box.add_child(texx)
	box.add_child(box2)
	box2.add_child(dir_label)
	box2.add_child(cli_label)
	box2.add_child(cant_label)
	box.add_child(del)
	del.connect("pressed", self, "_on_item_del_pressed", [panel])
	list.add_child(panel)
	static_api.make_request()

func _on_center_loaded():
	if get_node_or_null("Loading") != null:
		get_node("Loading").add_progress(50)

func _on_texture_updated(texture : ImageTexture):
	$HSplitContainer/ViewportContainer/TextureRect.texture = texture
	if get_node_or_null("Loading") != null:
		get_node("Loading").add_progress(50)
		if static_api.override_center:
			get_node("Loading").add_progress(50)

func _on_EnRoutar_pressed():
	static_api.request_directions(static_api.route_points.front(), static_api.route_points.back())

func _on_item_del_pressed(node):
	node.queue_free()
