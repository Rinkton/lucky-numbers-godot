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
	await G.get_tree().create_timer(1).timeout # dramatic pause
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
