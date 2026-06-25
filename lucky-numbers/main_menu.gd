extends Control


const GAME_PATH := "res://game.tscn"


func start_game():
	get_tree().change_scene_to_file(GAME_PATH)


func _on_human_vs_human_pressed():
	G.game_mode = G.GameMode.HUMAN_VS_HUMAN
	start_game()


func _on_human_vs_ai_pressed():
	G.game_mode = G.GameMode.HUMAN_VS_AI
	start_game()


func _on_ai_vs_ai_pressed():
	G.game_mode = G.GameMode.AI_VS_AI
	start_game()
