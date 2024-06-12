extends Control

@onready var ally_count = $AllyCount
@onready var enemy_count = $EnemyCount



func _on_launch_pressed():
	var main_scene: PackedScene = preload("res://Scenes/main.tscn")
	Singleton.ally_units_count = ally_count.value
	Singleton.enemy_units_count = enemy_count.value
	get_tree().change_scene_to_packed(main_scene)
