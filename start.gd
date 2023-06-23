extends Node

var PC = false

signal any_button

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("start")
	await $AnimationPlayer.animation_finished
	start()

func start():
	if OS.get_name() == "Web" or OS.get_name() == "Android" or OS.get_name() == "iOS":
		Global.efficiency_mode = true
	if OS.get_name() == "iOS":
		Global.sensitive_filesystem = true
	if ProjectSettings.get_setting("rendering/renderer/rendering_method") == "mobile":
		get_tree().change_scene_to_file("res://src/extras/menu/friendly_menu.tscn")
	else:
		get_tree().change_scene_to_file("res://src/extras/menu/menu.tscn")

# UI Input handling
func _input(_event):
	if Input.is_anything_pressed():
		start()
