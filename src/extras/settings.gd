extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_settings_pressed():
	settings_update()
	get_node("../anim").play("settings")

func _on_settings_exit_pressed():
	get_node("../anim").play_backwards("settings")

var setv = {
	"sm":"rendering/scaling_3d/mode",
	"lpm":"application/run/low_processor_mode",
	"msaa":"rendering/anti_aliasing/quality/msaa",
	"ssaa":"rendering/anti_aliasing/quality/screen_space_aa",
	"taa":"rendering/anti_aliasing/quality/use_taa"
}

func settings_update():
	for x in $menu/panel/vbox.get_children():
		if x.name == "efficent":
			x.get_node("label/button").button_pressed = Global.overlays
			continue
		if x.get_node("label/button") is OptionButton:
			x.get_node("label/button").selected = ProjectSettings.get_setting(setv[x.name])
		elif x.get_node("label/button") is CheckBox:
			x.get_node("label/button").button_pressed = ProjectSettings.get_setting(setv[x.name])
		elif x.get_node("label/button") is SpinBox:
			x.get_node("label/button").value = ProjectSettings.get_setting(setv[x.name])

func set_overlay(active):
	Global.overlays = active
	if active:
		if get_node_or_null("/root/World") == null:
			if get_node_or_null("../menu") == null:
				var background = load("res://src/extras/menu.tscn").instantiate()
				get_parent().add_child(background)
				get_parent().move_child(background, get_child_count())
		if get_node_or_null("/root/game_overlay") == null:
			var overlay = load("res://src/extras/overlay.tscn").instantiate()
			get_node("/root").add_child(overlay)
	else:
		if get_node_or_null("/root/World") == null:
			if get_node_or_null("../menu") != null:
				get_node_or_null("../menu").queue_free()
		if get_node_or_null("/root/game_overlay") != null:
			get_node_or_null("/root/game_overlay").queue_free()

func _on_setting_changed(setting_value, setting):
	ProjectSettings.set_setting(setv[setting], setting_value)
	settings_update()
