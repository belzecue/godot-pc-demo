extends RichTextLabel


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	percent_visible = wrapf(percent_visible + delta * 0.005, 0, 1.0)
