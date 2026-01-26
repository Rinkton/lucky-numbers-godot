extends Control


signal lmb

var is_mouse_in := false


func _input(event):
	if event is InputEventMouseButton and is_mouse_in:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			lmb.emit()
			get_parent().call_deferred("grab_focus")


func _on_mouse_entered():
	is_mouse_in = true


func _on_mouse_exited():
	is_mouse_in = false
