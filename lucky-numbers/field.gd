extends TextureRect
class_name Field


var player


func set_up_start_diagonal():
	for i in range(4):
		var cell = get_cell(i, i)
		var clover = G.game.clover_pile.pop_random_clover()
		cell.replace_clover(clover)


func get_is_this_clover_on_this_cell_acceptable(this_clover: Clover, this_cell: Cell) -> bool:
	var this_vector = get_vector_of_cell(this_cell)
	
	var up_cell = get_cell(this_vector.x, this_vector.y - 1)
	var left_cell = get_cell(this_vector.x - 1, this_vector.y)
	
	if is_instance_valid(up_cell) and up_cell.is_there_clover():
		if up_cell.get_clover().number >= this_clover.number:
			return false
	if is_instance_valid(left_cell) and left_cell.is_there_clover():
		if left_cell.get_clover().number >= this_clover.number:
			return false
	return true


func get_cell(x: int, y: int):
	return $VBoxContainer.get_child(y).get_child(x)


func get_vector_of_cell(cell: Cell) -> Vector2:
	for y in range($VBoxContainer.get_child_count()):
		var row = $VBoxContainer.get_child(y)
		for x in range(row.get_child_count()):
			if row.get_child(x) == cell:
				return Vector2(x, y)
	printerr("get_vector_of_cell didn't found the cell")
	return Vector2(-1, -1)
