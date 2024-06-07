extends Unit

@onready var selection_visual = $SelectionVisual

func toggle_selection_visual(toggle):
	selection_visual.visible = toggle
