extends PanelContainer

onready var confirm_dialog = $HSplitContainer/TabContainer/Tabs/VBoxContainer/Control/ConfirmationDialog
onready var icon = preload("res://location_icon.png")
func _ready():
	confirm_dialog.connect("request_new_point", self, "create_item")

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
