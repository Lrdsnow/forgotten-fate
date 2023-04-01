extends Control

func _ready():
	resize()
	$gui/gui_anim.play("RESET")
	if Global.player_held_item in Global.guns:
		$gui/gui_anim.play("open_stamina_health_ammo")
		Global.max_ammo = Global.guns_max_ammo[Global.player_held_item]
	elif Global.player_held_item in Global.lights:
		$gui/gui_anim.play("open_stamina_health_power")
	else:
		$gui/gui_anim.play("open_stamina_health")
	if Global.cinematic_mode:
		self.hide()
	else:
		self.show()

func _process(delta):
	update_stats()

func update_stats():
	$gui/bars/health.value = Global.health
	$gui/bars/stamina.value = Global.stamina
	$gui/bars/power.value = Global.power
	$gui/bars/ammo.value = Global.ammo_clip
	$gui/bars/ammo.max_value = Global.max_ammo
	$gui/bars/ammo/Label.text = str(Global.ammo_clip)
	$gui/bars/ammo/Label2.text = str("/\n" + str(Global.ammo))

func resize():
	#$gui.position.x = get_viewport().size.x - $gui.size.x - 50
	#$gui.position.y = get_viewport().size.y - $gui.size.y - 50
	$gui/cc.size.x = get_viewport().size.x
	$gui/cc.size.y = get_viewport().size.y
	$"..".size.x = get_viewport().size.x
	$"..".size.y = get_viewport().size.y
	$"gui/cc/cross/int-text".size.x = get_viewport().size.x
	$"gui/cc/cross/int-text".position.x = int(get_viewport().size.x - get_viewport().size.x*2) / 2 + 10


func _on_settings_pressed():
	pass # Replace with function body.