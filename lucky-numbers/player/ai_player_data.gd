extends Resource
class_name AiPlayerData


@export var motivation_position_curve: Curve
@export var estimate_position_quiality_coef: float = 10
@export var new_clover_mult: float = 1.2
@export var left_up_corner_coef: float = 100
# Если больше 1, то знач считает, что определённость лучше среднестатистической выгоды
@export var face_up_coef: float = 1
@export var unblocking_0_gap = 10
@export var unblocking_1_gap = 4


func randomize_genes():
	estimate_position_quiality_coef += randi_range(
		-estimate_position_quiality_coef/2, estimate_position_quiality_coef/2)
	new_clover_mult = 1 + randf()
	left_up_corner_coef += randi_range(
		-left_up_corner_coef/2, left_up_corner_coef/2)


static func get_gene_names():
	return ["estimate_position_quiality_coef", 
	"new_clover_mult", "left_up_corner_coef"]
