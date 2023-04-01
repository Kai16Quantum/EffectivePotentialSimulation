extends HSlider

var offset = Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready():
	offset = position
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var l = max_value-min_value
	$Label.position.x = value/l * size.x * 0.85 - 80.0
	$Label.text = str(value)
	pass
