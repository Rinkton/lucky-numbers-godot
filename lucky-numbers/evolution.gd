extends Node


var cur_players := get_initial_players()
var i_player := 0
var j_player := 0
var generation := 0


func get_initial_players() -> Array:
	var initial_players := []
	for i in range(20):
		var p = AiPlayer.new()
		p.data.randomize_genes()
		initial_players.append(p)
	return initial_players


func get_next_two_players() -> Array:
	if j_player >= len(cur_players)-1:
		j_player = i_player + 1
		i_player += 1
	j_player += 1
	# last player can't play with itself
	if i_player >= len(cur_players) - 1:
		# TODO: don't forget to make a right output, written in workbook
		# TODO: 20 players
		end_of_round_robin()
		return get_next_two_players()
	if i_player == j_player:
		printerr("i_player equals j_player!")
	return [cur_players[i_player], cur_players[j_player]]


func end_of_round_robin():
	var selected_players := pick_weighted_players(cur_players, 3) # 3 old players
	output_report(selected_players)
	var new_players := get_crossover_players(selected_players) # 20 new players
	mutate_players(new_players)
	cur_players = new_players
	i_player = 0
	j_player = 0


func get_crossover_players(selected_players: Array) -> Array:
	var crossover_players := get_initial_players()
	for gene_name in AiPlayerData.get_gene_names():
		crossover_gene(crossover_players, selected_players, gene_name)
	return crossover_players


func mutate_players(players):
	for p in players:
		for gene_name in AiPlayerData.get_gene_names():
			if randi_range(0, 100) < 20:
				var mult := randf_range(0.9, 1.1)
				p.data.set(gene_name, p.data.get(gene_name) * mult)


func crossover_gene(crossover_players, selected_players, gene_name: String):
	var minv = selected_players[0].data.get(gene_name)
	var maxv = minv
	for s in selected_players:
		if s.data.get(gene_name) < minv:
			minv = s.data.get(gene_name)
		elif s.data.get(gene_name) > maxv:
			maxv = s.data.get(gene_name)
	for c in crossover_players:
		var expand_koef := 0.4
		var length = maxv - minv
		var gap = expand_koef * length
		var v = randf_range(minv - gap, maxv + gap)
		c.data.set(gene_name, v)


func pick_weighted_players(players: Array, n: int) -> Array:
	if n <= 0 or players.is_empty():
		return []

	# Work on a copy and collect weights (clamped to 0 to handle negative values)
	var available := players.duplicate()
	var weights: Array[float] = []
	for p in available:
		weights.append(maxf(0.0, float(p.victory_count)))

	var result: Array = []
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	var picks := mini(n, available.size())
	for _i in picks:
		var total_weight := 0.0
		for w in weights:
			total_weight += w

		var idx: int
		if total_weight <= 0.0:
			# All remaining weights are zero → pick uniformly
			idx = rng.randi_range(0, available.size() - 1)
		else:
			idx = rng.rand_weighted(weights)

		result.append(available[idx])
		available.remove_at(idx)
		weights.remove_at(idx)

	return result


func output_report(selected_players):
	print("Generation №" + str(generation))
	for s in selected_players:
		var out := ""
		out += "max_wins: " + str(s.victory_count)
		for gene_name in AiPlayerData.get_gene_names():
			out += " | " + gene_name + ": " + str(round_place(s.data.get(gene_name), 2))
		print(out)
	print()
	generation += 1


func round_place(num, places):
	return (round(num*pow(10,places))/pow(10,places))
