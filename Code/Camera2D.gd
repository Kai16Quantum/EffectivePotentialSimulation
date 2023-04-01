extends Camera2D

var mouse_sensitivity = 0.01
var zoom_sensitivity = 0.05
var following = false

func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass

func _input(event):
	if event is InputEventMouseMotion:
		var offset = -event.relative * mouse_sensitivity
#		position += offset * (1/zoom.x) * 30.0
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_c(max(zoom.x - zoom_sensitivity, 0.75))
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_c(min(zoom.x + zoom_sensitivity, 2.5))

func zoom_c(scale_factor):
	var new_scale = scale * scale_factor
	zoom = new_scale

func _process(delta):
	if (following):
		var target_rot = Vector2.ZERO.angle_to_point(get_parent().get_node("Body").global_position)
		rotation = target_rot
	else:
		rotation = lerp(rotation, 0.0, 0.2)

func _on_check_box_toggled(button_pressed):
	following = !following

