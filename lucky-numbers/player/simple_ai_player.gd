extends AiPlayer
class_name SimpleAiPlayer


const FIELD_SIZE := 4
var data = load("res://player/simple_ai_player_data.tres").duplicate() as AiPlayerData

var my_field: Field
var enemy_field: Field
var victory_count := 0:
	set(value):
		victory_count = value
		victory_count = max(0, victory_count)


func _init():
	G.connect("game_set", _on_game_set)


func turn():
	#await G.get_tree().create_timer(1).timeout # dramatic pause
	# refactor it and make it work
	if G.game.clover_pile.is_there_clovers_left():
		var best_pos
		var best_clover
		var face_down_chosen: bool
		var start_score = score()
		for cell in G.game.face_up_pile.get_cells():
			var clover = cell.get_clover()
			var best = get_best_for_this_clover(start_score, clover)
			var score_const = 0
			if best["min_score"] + score_const < start_score:
				best_pos = best["best_pos"]
				best_clover = clover
		face_down_chosen = best_clover == null
		var face_up_cell
		if face_down_chosen:
			best_clover = G.game.clover_pile.pop_random_clover()
			var best = get_best_for_this_clover(start_score, best_clover)
			best_pos = best["best_pos"]
		else:
			var cell = best_clover.get_parent()
			face_up_cell = cell
			cell.remove_child(best_clover)
			cell.queue_free()
		if best_pos != null:
			var cell = my_field.get_cell(best_pos.x, best_pos.y)
			cell.put_clover_turn(best_clover, 
				G.game.clover_pile if face_down_chosen else face_up_cell)
		else:
			G.game.face_up_pile.put_clover_turn(best_clover)
	"""
	G.game.face_up_pile.put_clover_turn(clover)
	
	var cell = my_field.get_cell(best_moves[clover.number]["x"], best_moves[clover.number]["y"])
	cell.put_clover_turn(clover, G.game.clover_pile)
	
	var cell = face_up_dict["cell"]
	var best_move = best_moves[cell.get_clover().number]
	var field_cell = my_field.get_cell(best_move["x"], best_move["y"])
	var clover = cell.get_clover()
	cell.remove_child(clover)
	field_cell.put_clover_turn(clover, cell)
	all_clover_placements.append({"x": best_move["x"], "y": best_move["y"], 
		"number": field_cell.get_clover().number})
	cell.queue_free()
	"""


func get_best_for_this_clover(start_score, clover):
	var min_const := 1.0
	var min_score = start_score + 1
	var best_pos = null
	for y in range(4):
		for x in range(4):
			var cell = my_field.get_cell(x, y)
			if my_field.get_is_this_clover_on_this_cell_acceptable(clover, cell):
				if cell.is_there_clover():
					var imagine_score = score(Vector3i(x, y, clover.number))
					var replace_const = 2
					if imagine_score + replace_const < min_score:
						min_score = imagine_score
						best_pos = Vector2(x, y)
				else:
					var imagine_score = score(Vector3i(x, y, clover.number))
					var new_clover_const = -0.25
					if imagine_score - pow(abs(new_clover_const) * 
					my_field.get_busy_cells_count(), 1.2) < min_score:
						min_score = imagine_score
						best_pos = Vector2(x, y)
	return {"best_pos": best_pos, "min_score": min_score}


# lower - better
func score(imagine_clover: Vector3i = Vector3i(-1, -1, 0)):
	var total_stress := 0.0
	var total_unhappiness := 0.0
	for y in range(4):
		for x in range(4):
			var cell = my_field.get_cell(x, y)
			if cell.is_there_clover():
				total_unhappiness += unhappiness(cell, imagine_clover)
			else:
				total_stress += stress(cell, imagine_clover)
	return 1 * total_stress + 0.05 * total_unhappiness


# cell must be empty
func stress(cell, imagine_clover: Vector3i = Vector3i(-1, -1, 0)):
	return 1 / (_get_cell_flexibility(cell, imagine_clover)["flex"] + 1)


# cell must be full
func unhappiness(cell, imagine_clover: Vector3i = Vector3i(-1, -1, 0)):
	var sur = _get_cell_flexibility(cell, imagine_clover)
	var center_row = (sur["lv"] + sur["rv"]) / 2
	var center_col = (sur["uv"] + sur["dv"]) / 2
	if my_field.get_vector_of_cell(cell) == Vector2i(0, 0):
		center_row = 1
		center_col = 1
	elif my_field.get_vector_of_cell(cell) == Vector2i(3, 3):
		center_row = 20
		center_col = 20
	var v = cell.get_clover().number
	return abs(v - center_row) + (v - center_col)


## imagine_clover we consider that there is an additional (z) type clover on (x, y) cell 
func _get_cell_flexibility(cell: Cell, imagine_clover: Vector3i = Vector3i(-1, -1, 0)):
	var field: Field = cell.get_field()
	var vec = field.get_vector_of_cell(cell)
	var imagine_clover_pos = Vector2i(imagine_clover.x, imagine_clover.y)
	
	var u := 0
	var r := 0
	var d := 0
	var l := 0
	var uv := 0
	var rv := 21
	var dv := 21
	var lv := 0
	
	while vec.y - u >= 0:
		var this_vec = Vector2i(vec.x, vec.y - u)
		if this_vec == imagine_clover_pos:
			uv = imagine_clover.z
		elif this_vec != vec:
			var c = field.get_cell(this_vec.x, this_vec.y)
			if c.is_there_clover():
				uv = c.get_clover().number
				break
		u+=1
	while vec.x + r <= 3:
		var this_vec = Vector2i(vec.x + r, vec.y)
		if this_vec == imagine_clover_pos:
			rv = imagine_clover.z
		elif this_vec != vec:
			var c = field.get_cell(this_vec.x, this_vec.y)
			if c.is_there_clover():
				rv = c.get_clover().number
				break
		r+=1
	while vec.y + d <= 3:
		var this_vec = Vector2i(vec.x, vec.y + d)
		if this_vec == imagine_clover_pos:
			dv = imagine_clover.z
		elif this_vec != vec:
			var c = field.get_cell(this_vec.x, this_vec.y)
			if c.is_there_clover():
				dv = c.get_clover().number
				break
		d+=1
	while vec.x - l >= 0:
		var this_vec = Vector2i(vec.x - l, vec.y)
		if this_vec == imagine_clover_pos:
			lv = imagine_clover.z
		elif this_vec != vec:
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
	return {"flex": flexibility, "uv": uv, "rv": rv, "dv": dv, "lv": lv}


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
