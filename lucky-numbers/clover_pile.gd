extends Control
class_name CloverPile


var clovers := []


func _ready():
	for i in range(2):
		for n in range(20):
			var clover = Clover.new_scene(n+1)
			clovers.append(clover)
	$MouseChecker.connect("lmb", _on_lmb)


func pop_random_clover():
	var idx = randi_range(0, len(clovers)-1)
	return pop_clover(idx)


func pop_clover(idx):
	return clovers.pop_at(idx)


func is_there_clover():
	return is_instance_valid(get_clover())


func get_clover():
	for a in get_children():
		if a is Clover:
			return a
	return null


func _on_lmb():
	var game = await G.get_game()
	if game.cur_player is HumanPlayer:
		if not is_there_clover():
			var clover = pop_random_clover()
			add_child(clover)


func _on_focus_exited():
	if is_instance_valid(get_clover()):
		await get_tree().process_frame
		grab_focus()
