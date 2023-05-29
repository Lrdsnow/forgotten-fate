extends Control

func _ready():
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


func _on_settings_pressed():
	pass # Replace with function body.
