extends StaticBody3D

func _on_nurse_killzone_body_entered(body):
	if body.name == "Player":
		if Global.player.can_move:
			Global.player.stats.health = 0
