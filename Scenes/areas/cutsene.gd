extends Camera

func _ready():
	$ColorRect.rect_size.x = get_viewport().size.x
	$ColorRect2.rect_size.x = get_viewport().size.x
	$ColorRect2.rect_position = get_viewport().size - $ColorRect2.rect_size
	$cutsenetext.rect_size = $ColorRect2.rect_size
	$cutsenetext.rect_position = $ColorRect2.rect_position
