extends CanvasLayer

var debug_open = false
signal cITEM

# Called when the node enters the scene tree for the first time.
func _ready():
	resize()
	cITEM.connect(Global.update_items)
	for i in Global.all_items:
		$debug_panel/ingame/items_opt.add_item(i, Global.all_items.find(i))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("debug"):
		if ! debug_open:
			if Global.ingame:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				Global.paused=true
				Global.can_move=false
			update_vars()
			$anim.play("open")
			debug_open = true
		else:
			if Global.ingame:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				Global.paused=false
				Global.can_move=true
			$anim.play_backwards("open")
			debug_open = false

func resize():
	$debug_panel.size.y = get_viewport().size.y
	$debug_panel/inmenu.size.y = get_viewport().size.y
	$debug_panel/ingame.size.y = get_viewport().size.y

func update_vars():
	if Global.ingame:
		$debug_panel/ingame.show()
		$debug_panel/inmenu.hide()
		$debug_panel/ingame/fov_slider.value = get_node("/root/World/Player/collision/neck/head/player_camera").fov
		$debug_panel/ingame/items_opt.selected = Global.all_items.find(Global.player_held_item)
		$debug_panel/ingame/ammo_in.value = Global.ammo
		$debug_panel/ingame/health_slider.value = Global.health
		$debug_panel/ingame/stam_slider.value = Global.stamina
		$debug_panel/ingame/pwr_slider.value = Global.power
	else:
		$debug_panel/ingame.hide()
		$debug_panel/inmenu.show()
		$debug_panel/inmenu/debugui.button_pressed = Global.debug_ui
		$debug_panel/inmenu/efficent.button_pressed = Global.efficiency_mode


func _on_items_opt_pressed():
	Global.player_held_item = $debug_panel/ingame/items_opt.get_item_text($debug_panel/ingame/items_opt.selected)


func _on_health_slider_value_changed(value):
	Global.health = value


func _on_stam_slider_value_changed(value):
	Global.stamina = value


func _on_pwr_slider_value_changed(value):
	Global.power = value


func _on_fov_slider_value_changed(value):
	get_node("/root/World/Player/collision/neck/head/player_camera").fov = value


func _on_br_slider_value_changed(value):
	Global.env.adjustment_brightness = value


func _on_debugui_toggled(button_pressed):
	Global.debug_ui = button_pressed


func _on_fpstest_pressed():
	get_tree().change_scene_to_file("res://src/extras/fpstest0/player_fps_training.tscn")


func _on_efficent_toggled(button_pressed):
	Global.efficiency_mode = button_pressed
	Global.update_graphics.emit()
