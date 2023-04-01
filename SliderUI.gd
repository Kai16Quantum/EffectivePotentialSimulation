extends VBoxContainer

var showing = true
var initial_pos = Vector2.ZERO
var hiding_pos = Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready():
	initial_pos = position
	hiding_pos = position - Vector2(0,225)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	if (showing):
		var pos_tween = create_tween()
		pos_tween.tween_property(self, "position", hiding_pos, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		showing = false
	else:
		var pos_tween = create_tween()
		pos_tween.tween_property(self, "position", initial_pos, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		showing = true
