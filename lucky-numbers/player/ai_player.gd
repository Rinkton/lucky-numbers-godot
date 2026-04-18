extends Player
class_name AiPlayer


const FIELD_SIZE := 4
const DATA = preload("res://player/ai_player_data.tres") as AiPlayerData

var my_field: Field
var enemy_field: Field
var best_moves := {}


func _init():
	G.connect("game_set", _on_game_set)


func turn():
	var clover_pile_dict = _get_clover_pile_dict()
	# var a = my_field.get_cell(0, 0).get_clover().number
	# _get_cell_flexibility(my_field.get_cell(1, 1))
	_get_clover_pile_flexibility(my_field)
	#print("best ", best_moves)
	var clover = G.game.clover_pile.pop_random_clover()
	# TODO: Нужны хорошие гибкие рычаги калибровки, а также их редактура прям во время игры
	# TODO: Для worth нужно брать флекс всех 20 типов от хода на лучшую клетку и соответственно не делить
		# среднеарифметическое на 16
	# CloverPile может истощиться
	if is_instance_valid(clover):
		var cell = my_field.get_cell(best_moves[clover.number]["x"], best_moves[clover.number]["y"])
		cell.put_clover_turn(clover, G.game.clover_pile)
	print(best_moves[clover.number])


func _get_clover_pile_worth_for_me():
	var cur_empty = _get_flexibility(true, my_field)
	var cur_busy = _get_flexibility(false, my_field)
	var clover_pile_my_flexibility_dict = _get_clover_pile_flexibility(my_field)
	var new_empty = clover_pile_my_flexibility_dict["empty"]
	var new_busy = clover_pile_my_flexibility_dict["busy"]
	
	var count = _get_clovers_count_in_pile()
	# Новое
	# , делить на количество клеверов в куче(по итогу то мы получим только 1) и ещё на 16, ибо
	# Мы помимо клеток для выбора клевера перебирали ещё и ценность для остальных 15 клеток минус
	# ценность без клевера из кучи на поле
	var worth = (new_empty + new_busy) / (count * 16) - (cur_empty + cur_busy)
	
	return worth


func _get_flexibility(empty: bool, field: Field):
	var flexibility := 0
	for y in range(FIELD_SIZE):
		for x in range(FIELD_SIZE):
			var cell = field.get_cell(x, y)
			if cell.is_there_clover() == not empty:
				var cell_flexibility = _get_cell_flexibility(cell)
				flexibility += cell_flexibility
	return flexibility


func _get_clover_pile_flexibility(field: Field):
	var flexibility_empty := 0
	var flexibility_busy := 0
	var clover_pile_dict = _get_clover_pile_dict()
	best_moves = {}
	for i in range(1, 21):
		best_moves[i] = {"x": -1, "y": -1, "flex": 0}
	for i in range(1, 21):
		if clover_pile_dict[i] == 0:
			continue
		for y in range(FIELD_SIZE):
			for x in range(FIELD_SIZE):
				var clover_flexibility := 0
				if field.get_is_this_clover_on_this_cell_acceptable(
				Clover.new_scene(i), field.get_cell(x, y)):
					# for checking cells with our clover placed on (x, y)
					for yy in range(FIELD_SIZE):
						for xx in range(FIELD_SIZE):
							if xx == x and yy == y:
								continue
							var cell = field.get_cell(xx, yy)
							var cell_flexibility = _get_cell_flexibility(cell, Vector3i(x, y, i))
							clover_flexibility += cell_flexibility
				var cell = field.get_cell(x, y)
				clover_flexibility *= clover_pile_dict[i]
				if best_moves[i]["flex"] < clover_flexibility:
					# Для мотивации поставить новый клевер
					# Меньше, чем дальше к правому краю, ибо там flexibility ниже само по себе
					var motivation = 100 * (DATA.motivation_position_curve.sample((x + y + 1)/7))
					var final_clover_flexibility := clover_flexibility
					if not cell.is_there_clover():
						final_clover_flexibility += motivation
					best_moves[i] = {
						"x": x,
						"y": y,
						"flex": final_clover_flexibility,
					}
				if cell.is_there_clover():
					flexibility_busy += clover_flexibility
				else:
					flexibility_empty += clover_flexibility
	return {"busy": flexibility_busy, "empty": flexibility_empty}


## imagine_clover we consider that there is an additional (z) type clover on (x, y) cell 
func _get_cell_flexibility(cell: Cell, imagine_clover: Vector3i = Vector3i(-1, -1, 0)):
	var field: Field = cell.get_field()
	var vec = field.get_vector_of_cell(cell)
	var imagine_clover_pos = Vector2i(imagine_clover.x, imagine_clover.y)
	
	var u := 1
	var r := 1
	var d := 1
	var l := 1
	var uv := 0
	var rv := 21
	var dv := 21
	var lv := 0
	
	while vec.y - u >= 0:
		var this_vec = Vector2i(vec.x, vec.y - u)
		if this_vec == imagine_clover_pos:
			uv = imagine_clover.z
		else:
			var c = field.get_cell(this_vec.x, this_vec.y)
			if c.is_there_clover():
				uv = c.get_clover().number
				break
		u+=1
	while vec.x + r <= 3:
		var this_vec = Vector2i(vec.x + r, vec.y)
		if this_vec == imagine_clover_pos:
			rv = imagine_clover.z
		else:
			var c = field.get_cell(this_vec.x, this_vec.y)
			if c.is_there_clover():
				rv = c.get_clover().number
				break
		r+=1
	while vec.y + d <= 3:
		var this_vec = Vector2i(vec.x, vec.y + d)
		if this_vec == imagine_clover_pos:
			dv = imagine_clover.z
		else:
			var c = field.get_cell(this_vec.x, this_vec.y)
			if c.is_there_clover():
				dv = c.get_clover().number
				break
		d+=1
	while vec.x - l >= 0:
		var this_vec = Vector2i(vec.x - l, vec.y)
		if this_vec == imagine_clover_pos:
			lv = imagine_clover.z
		else:
			var c = field.get_cell(this_vec.x, this_vec.y)
			if c.is_there_clover():
				lv = c.get_clover().number
				break
		l+=1
	var min = max(lv, uv) + 1
	var max = min(rv, dv) - 1
	
	var flexibility := 0
	var number = min
	var clover_pile_dict = _get_clover_pile_dict()
	while number <= max:
		flexibility += clover_pile_dict[number]
		number += 1
	if field.get_vector_of_cell(cell) == Vector2i(1, 0) and imagine_clover == Vector3i(1, 1, 2) and false:
		print()
		print("=====")
		print("cell: ", field.get_vector_of_cell(cell))
		print("imagine_clover: ", imagine_clover)
		print(min, " ", max)
		print(uv, " ", rv, " ", dv, " ", lv)
		print("FINAL FLEX: ", flexibility)
	return flexibility


func _get_clover_pile_dict():
	var dict := {}
	for i in range(20):
		dict[i+1] = 0
	for clover in G.game.clover_pile.clovers:
		dict[clover.number] += 1
	return dict


func _get_clovers_count_in_pile():
	return len(G.game.clover_pile.clovers)


func _on_game_set():
	for field in G.game.get_fields():
		if field.player == self:
			my_field = field
		else:
			enemy_field = field
