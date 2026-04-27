extends Clover


@export var debug_number := 0


func _ready():
	super()
	$Label.text = str(debug_number)


func _on_button_pressed():
	G.debug_panel.show_moves_for_number(debug_number)


func _on_button_focus_entered():
	$Button.scale = Vector2(1.1, 1.1)


func _on_button_focus_exited():
	$Button.scale = Vector2(1, 1)
