extends Node


signal game_set

var game: Game:
	set(value):
		game = value
		game_set.emit()
var debug_panel:
	set(value):
		debug_panel = value


func get_game():
	if is_instance_valid(game):
		return game
	await game_set
	return game


func set_game(game_):
	game = game_
