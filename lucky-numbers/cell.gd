extends Control
class_name Cell


const SCENE = preload("res://cell.tscn")


func _ready():
	$MouseChecker.connect("lmb", _on_lmb)


static func new_scene():
	var scene = SCENE.instantiate()
	return scene


func replace_clover(clover: Clover):
	clear_clover()
	add_child(clover)


func is_there_clover():
	return is_instance_valid(get_clover())


func get_clover():
	for a in get_children():
		if a is Clover:
			return a
	return null


func clear_clover():
	for a in get_children():
		if a is Clover:
			a.queue_free()


func _on_lmb():
	if G.game.whos_this_cell(self) == G.game.cur_player:
		var focus_owner = get_viewport().gui_get_focus_owner()
		# TODO: it also depends on whos this cell is, make a table of it and make the logic right and clear
		if focus_owner is CloverPile and focus_owner.is_there_clover():
			var prev_clover = get_clover()
			remove_child(prev_clover)
			var clover = focus_owner.get_clover()
			focus_owner.remove_child(clover)
			replace_clover(clover)
			G.game.face_up_pile.add_clover(prev_clover)
