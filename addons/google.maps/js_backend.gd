extends Node
class_name JsLocations
signal location_found(where)

func get_user_position() -> Vector2:
	var init = JavaScript.eval("""
	var Lat = 0; var Lon = 0;
	function showPosition(position) {  
		Lat = position.coords.latitude;
		Lon = position.coords.longitude }
		
	function getLocation() {
	if (navigator.geolocation) {
	return navigator.geolocation.getCurrentPosition(showPosition);
  	} 
  }
	getLocation();  
		""", true)
	return _get_result()

func _get_result() -> Vector2: 
	yield(get_tree().create_timer(2), "timeout")
	var js = JavaScript.eval("Lat;", true)
	var js2 = JavaScript.eval("Lon;", true)
	if js != null and js2 != null:
		print(str(str(js)+","+str(js2)))
		emit_signal("location_found", Vector2(js, js2))
		return Vector2(js, js2)
	else:
		print("trying again")
		return _get_result()
