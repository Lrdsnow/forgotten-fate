extends Node

var PC = false

signal any_button

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("start")
	await $AnimationPlayer.animation_finished
	start()

func start():
	Game.setup_discord()
	match OS.get_name():
		"Windows", "UWP", "Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD", "macOS":
			PC = true
		"iOS", "Web":
			Global.sensitive_filesystem = true
	if not PC:
		get_tree().change_scene_to_file("res://friendly_menu.tscn")
	else:
		get_tree().change_scene_to_file("res://new_menu.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# UI Input handling
func _input(event):
	if Input.is_anything_pressed():
		start()
