extends Node2D

var selected_units: Array[CharacterBody2D]
var players: Array[CharacterBody2D]
var enemies: Array[CharacterBody2D]


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
	unit.killed.connect(_on_unit_killed)
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
	

func _on_unit_killed(unit):
	_unselect_unit(unit)

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
