extends Node


func get_focus_owner_that_sharing_clover():
	var focus_owner = get_viewport().gui_get_focus_owner()
	if not is_instance_valid(focus_owner):
		return
	if not focus_owner.is_there_clover():
		return
	if not(focus_owner is CloverPile or focus_owner.get_is_in_face_up_pile()):
		return
	return focus_owner
