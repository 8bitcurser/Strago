extends Node2D

@onready var win_or_lose = $WinOrLose

var selected_units: Array[CharacterBody2D]
var players: Array[CharacterBody2D]
var enemies: Array[CharacterBody2D]
var killed_players: int = 0


func _ready():
	const enemy_scene: PackedScene = preload("res://Scenes/enemy_unit.tscn")
	const player_scene: PackedScene = preload("res://Scenes/player_unit.tscn")
	for i in range(Singleton.enemy_units_count):
		var enemy = enemy_scene.instantiate()
		add_child(enemy)
		enemy.global_position.x = randi_range(45,126)
		enemy.global_position.y = randi_range(-50,50)

	for i in range(Singleton.ally_units_count):
		var player = player_scene.instantiate()
		add_child(player)
		player.global_position.x = randi_range(-130,-50)
		player.global_position.y = randi_range(-50,50)

	for player in players:
		player.killed.connect(_on_unit_killed)

	for enemy in enemies:
		enemy.killed.connect(_on_unit_killed)
		
	

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_try_select_unit()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_try_command_unit()
	

func _get_selected_unit():
	var space = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = get_global_mouse_position()
	var intersection = space.intersect_point(query, 1)

	if !intersection.is_empty():
		return intersection[0].collider
	return null

func _try_select_unit():
	var unit = _get_selected_unit()
	if unit != null and unit.is_player:
		_select_unit(unit)
	else:
		_unselect_unit()

func _select_unit(unit):
	if unit in selected_units:
		_unselect_unit(unit)
		return
	selected_units.append(unit)
	for selected_unit in selected_units:
		selected_unit.toggle_selection_visual(true)

func _unselect_unit(removed_unit: CharacterBody2D=null):
	var unit_idx = 0
	if removed_unit != null:
		removed_unit.toggle_selection_visual(false)
		removed_unit.disconnect('killed', _on_unit_killed)
		for i in selected_units.size():
			if selected_units[i] == removed_unit:
				unit_idx = i
		selected_units.remove_at(unit_idx)

func _remove_enemy(slained_enemy: CharacterBody2D=null):
	var unit_idx = 0
	for i in enemies.size():
		if enemies[i] == slained_enemy:
			unit_idx = i
	enemies.remove_at(unit_idx)

func _display_win_or_lose():
	if enemies.size() == 0:
		get_tree().paused = true
		win_or_lose.visible = true
		win_or_lose.get_node("Lose").visible = false
	if killed_players == players.size():
		get_tree().paused = true
		win_or_lose.visible = true
		win_or_lose.get_node("Win").visible = false

func _on_unit_killed(unit):
	if unit != null and unit.is_player == true:
		_unselect_unit(unit)
		killed_players += 1
	elif unit != null and unit.is_player == false:
		_remove_enemy(unit)
	_display_win_or_lose()

func _try_command_unit():
	if len(selected_units) == 0:
		return
	var target = _get_selected_unit()
	if target != null and target.is_player == false:
		for selected_unit in selected_units:
			selected_unit.set_target(target)
	else:
		for selected_unit in selected_units:
			if selected_unit != null:
				selected_unit.move_to_location(get_global_mouse_position())
