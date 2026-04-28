extends TextureRect
class_name Field


var player


func _ready():
	var game = await G.get_game()
	game.connect("ended_turn", _on_game_ended_turn)
	$StateLabel.visible = game.cur_player == player


func set_up_start_diagonal():
	var clovers := []
	for i in range(4):
		var game = await G.get_game()
		var clover = game.clover_pile.pop_random_clover()
		clovers.append(clover)
	clovers.sort_custom(func(a, b): return a.number < b.number)
	for i in range(4):
		var cell = get_cell(i, i)
		cell.replace_clover(clovers[i])
	"""
	for i in range(4):
		for j in range(4):
			if randi_range(0, 2) == 0:
				continue
			var cell = get_cell(i, j)
			var game = await G.get_game()
			var clover = game.clover_pile.pop_random_clover()
			cell.replace_clover(clover)
	"""


func get_is_this_clover_on_this_cell_acceptable(this_clover: Clover, this_cell: Cell) -> bool:
	var this_vector = get_vector_of_cell(this_cell)
	
	var up_cell = get_cell(this_vector.x, this_vector.y - 1)
	var right_cell = get_cell(this_vector.x + 1, this_vector.y)
	var down_cell = get_cell(this_vector.x, this_vector.y + 1)
	var left_cell = get_cell(this_vector.x - 1, this_vector.y)
	
	if is_instance_valid(up_cell) and up_cell.is_there_clover():
		if up_cell.get_clover().number >= this_clover.number:
			return false
	if is_instance_valid(right_cell) and right_cell.is_there_clover():
		if right_cell.get_clover().number <= this_clover.number:
			return false
	if is_instance_valid(down_cell) and down_cell.is_there_clover():
		if down_cell.get_clover().number <= this_clover.number:
			return false
	if is_instance_valid(left_cell) and left_cell.is_there_clover():
		if left_cell.get_clover().number >= this_clover.number:
			return false
	return true


func get_cell(x: int, y: int):
	if x < 0 or y < 0:
		return
	if x > 3 or y > 3:
		return
	return $VBoxContainer.get_child(y).get_child(x)


func get_vector_of_cell(cell: Cell) -> Vector2i:
	for y in range($VBoxContainer.get_child_count()):
		var row = $VBoxContainer.get_child(y)
		for x in range(row.get_child_count()):
			if row.get_child(x) == cell:
				return Vector2i(x, y)
	printerr("get_vector_of_cell didn't found the cell")
	return Vector2i(-1, -1)


func get_is_full():
	for row in $VBoxContainer.get_children():
		for cell in row.get_children():
			if not is_instance_valid(cell.get_clover()):
				return false
	return true


func _on_game_ended_turn():
	var game = await G.get_game()
	if get_is_full():
		$StateLabel.text = "Победа!"
		$StateLabel.add_theme_color_override("font_color", Color.GREEN)
		game.end_of_game(player)
		game.cur_player = null
	else:
		$StateLabel.visible = game.cur_player == player
