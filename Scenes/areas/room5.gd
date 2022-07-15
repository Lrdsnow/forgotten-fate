extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var ad = true
var doorname

# Called when the node enters the scene tree for the first time.
func _on_room5():
	get_node("/root/World/Player").connect("interact", self, "_on_interact")
	#get_node("/root/World/Player").connect("door", self, "_on_door")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area_body_entered(body):
	if ad == false:
		get_node("/root/World/Player/CollisionShape/Neck/Head/Camera/cent/crosshair/interaction").text = ""
		get_node("/root/World/Player").movement = false
		get_node("/root/World/Player").hide()
		$cutsene/ColorRect.show()
		$cutsene/AnimationPlayer.play("cutsene")
		ad = true
	

func _on_door():
	doorname = get_node("/root/World/Player").doorname
	if doorname == "door":
		get_node("/root/World/Player/CollisionShape/Neck/Head/Camera/cent/crosshair/interaction").text = "E - Open"
		print("loooked")
		if Input.is_action_pressed("interact"):
			print("pressed")
			if ! Playerglobal.dend:
				get_tree().change_scene("res://Scenes/end.tscn")
			else:
				get_node("things/exitdoor/").queue_free()
	else:
		get_node("/root/World/Player/CollisionShape/Neck/Head/Camera/cent/crosshair/interaction").text = "Locked"

func _on_AnimationPlayer_animation_finished(anim_name):
	if ad:
		#$cutsene.current = false
		#$cutsene/ColorRect.hide()
		#$".."/".."/".."/Player/CollisionShape/Neck/Head/Camera/cent/crosshair/interaction.text = ""
		#$".."/".."/".."/Player.movement = true
		#$".."/".."/".."/Player.show()
		#emit_signal("done
		pass
