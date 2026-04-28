extends Control
class_name Game


signal ended_turn

var players
var cur_player

@onready var clover_pile = $CloverPile
@onready var face_up_pile = $FaceUpPile


func _ready():
	players = Evolution.get_next_two_players()
	cur_player = players[0]
	$Field.set_up_start_diagonal()
	$Field.player = players[0]
	$Field2.set_up_start_diagonal()
	$Field2.player = players[1]
	G.set_game(self)
	if cur_player is AiPlayer:
		cur_player.turn()


func get_fields():
	return [$Field, $Field2]


func end_turn():
	players.reverse()
	cur_player = players[0]
	await get_tree().process_frame
	ended_turn.emit()
	if cur_player is AiPlayer:
		cur_player.turn()


# for generation specifically
func end_of_game(who_won: AiPlayer):
	if who_won:
		who_won.victory_count += 1
		print("win")
	get_tree().reload_current_scene()


func whos_this_cell(cell):
	if $Field.is_ancestor_of(cell):
		return $Field.player
	elif $Field2.is_ancestor_of(cell):
		return $Field2.player
	else:
		return null
