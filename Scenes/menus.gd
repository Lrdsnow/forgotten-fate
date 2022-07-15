extends Control

func _ready():
	$blur.hide()
	$pause.hide()
	$blur.rect_size = get_viewport_rect().size
	$pause.rect_size.y = get_viewport_rect().size.y
	$".."/CollisionShape/Neck/Head/Camera/cent.rect_size = get_viewport_rect().size
	get_node("../gui").rect_position.y = get_viewport_rect().size.y - 246
	get_node("../gui").rect_position.x = 30
	
	$info.rect_position.y = get_viewport().size.y - $info.rect_size.y
	$info.rect_size.x = get_viewport().size.x
	$vhs/VHS.rect_size = get_viewport_rect().size

signal unpause

var pani = false

func _on_Player_pause():
	$blur.show()
	$pause.show()
	$AnimationPlayer.play("pause")


func _on_Player_unpause():
	pani = true
	$AnimationPlayer.play_backwards("pause")


func _on_AnimationPlayer_animation_finished(anim_name):
	if pani:
		$blur.hide()
		$pause.hide()
		pani = false


func _on_exit_pressed():
	get_tree().quit()


func _on_save_pressed():
	Playerglobal.save_game()


func _on_continue_pressed():
	emit_signal("unpause")
	_on_Player_unpause()
