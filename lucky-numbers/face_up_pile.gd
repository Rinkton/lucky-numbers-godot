extends Control
class_name FaceUpPile


func _process(delta):
	$Panel.visible = false
	var focus_owner = Utils.get_focus_owner_that_sharing_clover()
	if not is_instance_valid(focus_owner):
		return
	if focus_owner is Cell: # means that it`s in face_up_pile
		return
	$Panel.visible = true


func add_clover(clover):
	var cell = Cell.new_scene()
	cell.replace_clover(clover)
	$HBoxContainer.add_child(cell)


"""
func remove_cell(cell):
	if cell in $HBoxContainer.get_children():
		$HBoxContainer.remove_child(cell)
	else:
		printerr("no cell in face_up_pile to remove_cell")
"""


func _on_panel_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var focus_owner = Utils.get_focus_owner_that_sharing_clover()
			if not is_instance_valid(focus_owner):
				return
			
			var clover = focus_owner.get_clover()
			focus_owner.remove_child(clover)
			add_clover(clover)
