extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var ad = false
var doorname

# Called when the node enters the scene tree for the first time.
func _on_room5():
	$".."/".."/".."/Player.connect("interact", self, "_on_interact")
	$".."/".."/".."/Player.connect("door", self, "_on_door")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area_body_entered(body):
	if ad == false:
		$".."/".."/".."/Player/CollisionShape/Neck/Head/Camera/cent/crosshair/interaction.text = ""
		$".."/".."/".."/Player.movement = false
		$".."/".."/".."/Player.hide()
		$cutsene/ColorRect.show()
		$cutsene/AnimationPlayer.play("cutsene")
		ad = true
	

func _on_door():
	doorname = $".."/".."/".."/Player.doorname
	if doorname == "door":
		if $".."/room3.ad == false:
			$".."/".."/".."/Player/CollisionShape/Neck/Head/Camera/cent/crosshair/interaction.text = "Locked"
		else:
			$".."/".."/".."/Player/CollisionShape/Neck/Head/Camera/cent/crosshair/interaction.text = "E - Open"
			if Input.is_action_just_pressed("interact"):
				$room/door.hide()
				$room/door/doorcollison.disabled = true
				print("Opened door")
	else:
		$".."/".."/".."/Player/CollisionShape/Neck/Head/Camera/cent/crosshair/interaction.text = "Locked"

func _on_AnimationPlayer_animation_finished(anim_name):
	if ad:
		$cutsene.current = false
		$cutsene/ColorRect.hide()
		$".."/".."/".."/Player/CollisionShape/Neck/Head/Camera/cent/crosshair/interaction.text = ""
		$".."/".."/".."/Player.movement = true
		$".."/".."/".."/Player.show()
		emit_signal("done")
