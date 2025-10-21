extends TextureRect


var player


func set_up_start_diagonal():
	for i in range(4):
		var cell = get_cell(i, i)
		var clover = G.game.clover_pile.pop_random_clover()
		cell.replace_clover(clover)


func get_cell(x: int, y: int):
	return $VBoxContainer.get_child(y).get_child(x)
