extends Control
class_name Game


var players
var cur_player

@onready var clover_pile = $CloverPile
@onready var face_up_pile = $FaceUpPile


func _ready():
	G.game = self
	players = [HumanPlayer.new(), HumanPlayer.new()]
	cur_player = players[0]
	$Field.set_up_start_diagonal()
	$Field.player = players[0]
	$Field2.set_up_start_diagonal()
	$Field2.player = players[1]


func end_turn():
	players.reverse()
	cur_player = players[0]


func whos_this_cell(cell):
	if $Field.is_ancestor_of(cell):
		return $Field.player
	elif $Field2.is_ancestor_of(cell):
		return $Field2.player
	else:
		return null
