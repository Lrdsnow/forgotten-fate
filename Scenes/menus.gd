extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

signal unpause

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

var pani = false

func _on_Player_pause():
	show()
	$AnimationPlayer.play("pause")


func _on_Player_unpause():
	pani = true
	$AnimationPlayer.play_backwards("pause")


func _on_AnimationPlayer_animation_finished(anim_name):
	if pani:
		hide()
		pani = false


func _on_exit_pressed():
	get_tree().quit()


func _on_save_pressed():
	pass # Replace with function body.


func _on_continue_pressed():
	emit_signal("unpause")
	_on_Player_unpause()
