extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var ad = Playerglobal.ad

var idk = Playerglobal.idk

signal done

# Called when the node enters the scene tree for the first time.
func _ready():
	$cutsene.current = false
	$cutsene/ColorRect.hide()
	$cutsene/ColorRect2.hide()
	$cutsene/nurse/nursecollision.disabled = true
	get_node("/root/World/Player").connect("interact", self, "_on_interact")
	$cutsene/cutsenetext.rect_position.y = get_viewport().size.y - $cutsene/cutsenetext.rect_size.y
	$cutsene/cutsenetext.rect_size.x = get_viewport().size.x
	get_node("/root/World/Terrains/hospitalfloor1/room2").connect("cutscene", self, "_on_room2_cutsene")



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_room2_cutsene():
	print("r2c")
	if idk == true:
		get_node("/root/World/Player/CollisionShape/Neck/Head/Camera/cent/crosshair/interaction").text = ""
		get_node("/root/World/Player/CollisionShape/Neck/Head/Camera").current = false
		get_node("/root/World/Player").movement = false
		get_node("/root/World/Player").hide()
		$cutsene.current = true
		$cutsene/ColorRect.show()
		$cutsene/ColorRect2.show()
		$cutsene/AnimationPlayer.play("cutsene")
	

func _on_interact():
	if ad:
		if idk:
			done()

func _on_AnimationPlayer_animation_finished(anim_name):
	print("done")
	ad = true
	get_node("/root/World/Player/CollisionShape/Neck/Head/Camera/cent/crosshair/interaction").text = "E - Get Up"

func done():
	print("alldone")
	if ad: 
		$cutsene/AnimationPlayer.play("setup")
	$cutsene.current = false
	$cutsene/ColorRect.hide()
	$cutsene/ColorRect2.hide()
	get_node("/root/World/Player/CollisionShape/Neck/Head/Camera/cent/crosshair/interaction").text = ""
	get_node("/root/World/Player/CollisionShape/Neck/Head/Camera").current = true
	get_node("/root/World/Player").movement = true
	get_node("/root/World/Player").show()
	emit_signal("done")
	ad = false
	idk = false
