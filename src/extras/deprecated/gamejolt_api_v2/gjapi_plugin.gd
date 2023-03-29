@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("GameJoltAPI", "HTTPRequest", preload("res://addons/gamejolt_api_v2/main.gd"), preload("res://addons/gamejolt_api_v2/gj_icon.png"))

func _exit_tree():
	remove_custom_type("GameJoltAPI")
