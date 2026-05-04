extends Resource
class_name AiPlayerData


#@export var motivation_position_curve: Curve
#@export var estimate_position_quiality_coef: float = 10
@export var new_clover_mult: float = 1.2
#@export var left_up_corner_coef: float = 100
#@export var irreplacability_coef: float = 100
# Если больше 1, то знач считает, что определённость лучше среднестатистической выгоды
#@export var face_up_coef: float = 1


func randomize_genes():
	new_clover_mult = 1 + randf()


static func get_gene_names():
	return ["new_clover_mult"]
