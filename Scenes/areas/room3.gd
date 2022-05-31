extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var ad = false

signal done

# Called when the node enters the scene tree for the first time.
func _ready():
	$cutsene/ColorRect.hide()
	$cutsene/ColorRect2.hide()
	$cutsene/nurse/nursecollision.disabled = true
	$".."/".."/".."/Player.connect("interact", self, "_on_interact")



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_room2_cutsene():
	if ad == false:
		$".."/".."/".."/Player/CollisionShape/Neck/Head/Camera/cent/crosshair/interaction.text = ""
		$".."/".."/".."/Player/CollisionShape/Neck/Head/Camera.current = false
		$".."/".."/".."/Player.movement = false
		$".."/".."/".."/Player.hide()
		$cutsene.current = true
		$cutsene/ColorRect.show()
		$cutsene/ColorRect2.show()
		$cutsene/AnimationPlayer.play("cutsene")
	

func _on_interact():
	if ad:
		done()

func _on_AnimationPlayer_animation_finished(anim_name):
	print("done")
	ad = true
	$".."/".."/".."/Player/CollisionShape/Neck/Head/Camera/cent/crosshair/interaction.text = "E - Get Up"

func done():
	print("alldone")
	if ad: 
		$cutsene/AnimationPlayer.play("setup")
	$cutsene.current = false
	$cutsene/ColorRect.hide()
	$cutsene/ColorRect2.hide()
	$".."/".."/".."/Player/CollisionShape/Neck/Head/Camera/cent/crosshair/interaction.text = ""
	$".."/".."/".."/Player/CollisionShape/Neck/Head/Camera.current = true
	$".."/".."/".."/Player.movement = true
	$".."/".."/".."/Player.show()
	emit_signal("done")
