extends Node


func get_focus_owner_that_sharing_clover():
	var focus_owner = get_viewport().gui_get_focus_owner()
	if not is_instance_valid(focus_owner):
		return
	if not focus_owner.is_there_clover():
		return
	if not(focus_owner is CloverPile):
		return
	return focus_owner
