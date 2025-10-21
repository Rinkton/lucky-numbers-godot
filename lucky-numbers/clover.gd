extends Sprite2D
class_name Clover


const SCENE = preload("res://clover.tscn")


var number: int:
	set(value):
		number = value
		$Label.text = str(number)


func _ready():
	get_parent().connect("focus_entered", _on_parent_focus_entered)
	get_parent().connect("focus_exited", _on_parent_focus_exited)


static func new_scene(number: int):
	var scene = SCENE.instantiate()
	scene.number = number
	return scene


func _on_parent_focus_entered():
	frame = 2


func _on_parent_focus_exited():
	frame = 1
