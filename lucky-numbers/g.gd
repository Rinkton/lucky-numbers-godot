extends Node


signal _game_set

var _game: Game:
	set(value):
		_game = value
		_game_set.emit()


func get_game():
	if is_instance_valid(_game):
		return _game
	await _game_set
	return _game


func set_game(game):
	_game = game
