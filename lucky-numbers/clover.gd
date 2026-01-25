extends Sprite2D
class_name Clover


const SCENE = preload("res://clover.tscn")


var number: int:
	set(value):
		number = value
		$Label.text = str(number)


static func new_scene(number: int):
	var scene = SCENE.instantiate()
	scene.number = number
	return scene


func _on_parent_focus_entered():
	frame = 2


func _on_parent_focus_exited():
	frame = 1


func _on_tree_entered():
	get_parent().connect("focus_entered", _on_parent_focus_entered)
	get_parent().connect("focus_exited", _on_parent_focus_exited)


func _on_tree_exiting():
	get_parent().disconnect("focus_entered", _on_parent_focus_entered)
	get_parent().disconnect("focus_exited", _on_parent_focus_exited)
