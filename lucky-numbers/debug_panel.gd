extends Control


@onready var color_rect = $ColorRect

var all_moves
var my_field: Field


func _ready():
	color_rect.visible = false
	if visible:
		get_window().position = Vector2i(100, 100)
	G.debug_panel = self


func _process(delta):
	if get_global_mouse_position().x <= 690:
		color_rect.visible = false


func set_all_moves(_all_moves, _my_field):
	all_moves = _all_moves
	my_field = _my_field


func show_moves_for_number(number):
	if number in all_moves:
		var i := 0
		for y in range(4):
			for x in range(4):
				var cell = $ColorRect/Field.get_cell(x, y)
				cell.get_node("DebugLabel").text = str(all_moves[number][i]["flex"])
				i += 1
	else:
		var cell = $ColorRect/Field.get_cell(0, 0)
		cell.get_node("DebugLabel").text = "no clover"


func _on_open_panel_mouse_entered():
	color_rect.visible = true
