extends Node


signal game_set

enum GameMode {
	HUMAN_VS_HUMAN,
	HUMAN_VS_AI,
	AI_VS_AI,
}

var game: Game:
	set(value):
		game = value
		game_set.emit()
var debug_panel:
	set(value):
		debug_panel = value
var game_mode: GameMode


func get_game():
	if is_instance_valid(game):
		return game
	await game_set
	return game


func set_game(game_):
	game = game_
