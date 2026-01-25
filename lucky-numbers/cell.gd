extends Control
class_name Cell


const SCENE = preload("res://cell.tscn")


func _ready():
	$MouseChecker.connect("lmb", _on_lmb)


static func new_scene():
	var scene = SCENE.instantiate()
	return scene


# TODO face_up cells won't have field
func get_field() -> Field:
	var node = get_parent()
	while not(node is Field):
		node = node.get_parent()
	return node


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
		var focus_owner = Utils.get_focus_owner_that_sharing_clover()
		if not is_instance_valid(focus_owner):
			return
		var clover = focus_owner.get_clover()
		if not is_instance_valid(clover):
			return
		if not get_field().get_is_this_clover_on_this_cell_acceptable(clover, self):
			modulate = Color.RED
			await get_tree().create_timer(0.5).timeout
			modulate = Color.WHITE
			return
		if focus_owner is CloverPile:
			var prev_clover = get_clover()
			if is_instance_valid(prev_clover):
				remove_child(prev_clover)
			focus_owner.remove_child(clover)
			replace_clover(clover)
			if is_instance_valid(prev_clover):
				G.game.face_up_pile.add_clover(prev_clover)
