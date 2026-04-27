extends Player
class_name AiPlayer


const FIELD_SIZE := 4
const DATA = preload("res://player/ai_player_data.tres") as AiPlayerData

var my_field: Field
var enemy_field: Field
var best_moves := {}
var all_moves := {}


func _init():
	G.connect("game_set", _on_game_set)


func turn():
	all_moves = {}
	var clover_pile_dict = _get_clover_pile_dict()
	# var a = my_field.get_cell(0, 0).get_clover().number
	# _get_cell_flexibility(my_field.get_cell(1, 1))
	_get_clover_pile_flexibility(my_field)
	#print("best ", best_moves)
	var clover = G.game.clover_pile.pop_random_clover()
	print(clover.number)
	# TODO: Нужны хорошие гибкие рычаги калибровки, а также их редактура прям во время игры
	# TODO: Для worth нужно брать флекс всех 20 типов от хода на лучшую клетку и соответственно не делить
		# среднеарифметическое на 16
	# TODO: Под конец игры начинает ставить клеверы на невозможные клетки
	# CloverPile может истощиться
	if is_instance_valid(clover):
		print(best_moves[clover.number])
		var cell = my_field.get_cell(best_moves[clover.number]["x"], best_moves[clover.number]["y"])
		if not cell.is_there_clover():
			print("empty cell")
		else:
			print("replaced: " + str(cell.get_clover().number))
		cell.put_clover_turn(clover, G.game.clover_pile)
	print("coef: " + str(estimate_position_quality(best_moves[clover.number]["x"], 
		best_moves[clover.number]["y"], clover.number)))
	G.debug_panel.set_all_moves(all_moves, my_field)
	#print()
	#print()
	#for i in range(1, 21):
	#	if i in all_moves:
	#		print(str(i) + "              " + str(all_moves[i]))


func print_best_moves(best_moves):
	for i in range(1, 21):
		print(str(i) + " " + str(best_moves[i]))


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
	var worth = (new_empty + new_busy) / (count) - (cur_empty + cur_busy)
	
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
				
				# Для мотивации поставить новый клевер
				# Меньше, чем дальше к правому краю, ибо там flexibility выше само по себе
				var motivation = DATA.left_up_corner_coef * \
					(DATA.motivation_position_curve.sample((x + y + 1)/7))

				motivation += estimate_position_quality(x, y, i) * DATA.estimate_position_quiality_coef
				var final_clover_flexibility := clover_flexibility
				if clover_flexibility != 0:
					final_clover_flexibility += motivation
				if not cell.is_there_clover():
					final_clover_flexibility *= DATA.new_clover_mult
				# Во, терь точно не будет ставить куда нельзя ставить
				if not my_field.get_is_this_clover_on_this_cell_acceptable(
				Clover.new_scene(i), cell):
					final_clover_flexibility = -1
				
				if not (i in all_moves):
					all_moves[i] = []
				all_moves[i].append({
					"x": x,
					"y": y,
					"flex": str(final_clover_flexibility) + " - \n" + str(int(motivation)),
				})
				
				if best_moves[i]["flex"] < final_clover_flexibility:
					best_moves[i] = {
						"x": x,
						"y": y,
						"flex": final_clover_flexibility,
					}
				if cell.is_there_clover():
					flexibility_busy += best_moves[i]["flex"]
				else:
					flexibility_empty += best_moves[i]["flex"]
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


func estimate_position_quality(x: int, y: int, number: int) -> float:
	# Position value: 0 for (0,0), 1 for (3,3)
	var position_weight: float = float(x + y) / 6.0
	
	# Expected number for this position: 1 for (0,0), 20 for (3,3)
	var expected_number: float = 1.0 + position_weight * 19.0
	
	# How far is actual number from expected? (0 to 19)
	var deviation: float = abs(float(number) - expected_number)
	
	# Maximum possible deviation is 19
	var quality: float = 1.0 - (deviation / 19.0)
	
	return quality


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
