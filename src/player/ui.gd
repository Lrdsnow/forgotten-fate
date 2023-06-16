extends Control

func _ready():
	if Global.player.held_item.name in Global.guns:
		$gui/gui_anim.play("open_stamina_health_ammo")
		Global.player.stats.max_ammo = Global.guns_max_ammo[Global.player.held_item.name]
	elif Global.player.held_item.name in Global.lights:
		$gui/gui_anim.play("open_stamina_health_power")
	else:
		$gui/gui_anim.play("open_stamina_health")

func _process(_delta):
	update_stats()

func update_stats():
	$gui/bars/health.value = Global.player.stats.health
	$gui/bars/stamina.value = Global.player.stats.stamina
	$gui/bars/power.value = Global.player.stats.power
	$gui/bars/ammo.value = Global.player.stats.ammo_clip
	$gui/bars/ammo.max_value = Global.player.stats.max_ammo
	$gui/bars/ammo/Label.text = str(Global.player.stats.ammo_clip)
	$gui/bars/ammo/Label2.text = str("/\n" + str(Global.player.stats.ammo))


func _on_settings_pressed():
	pass # Replace with function body.
