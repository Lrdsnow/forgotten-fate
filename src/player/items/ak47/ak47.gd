extends StaticBody3D

func ogshoot(pos):
	var b = load("res://src/player/items/ak47/bullet.tscn").instantiate()
	owner.add_child(b)
	b.transform = pos.global_transform
	b.velocity = -b.transform.basis.z * b.muzzle_velocity

func shoot(plr_rot, plr_pos):
	var bullet = load("res://src/player/items/ak47/bullet.tscn").instantiate()
	self.add_child(bullet)
	bullet.position = Vector3(-0.157, 0.169, -0.135)
	bullet.rotation = Vector3(0,0,90)
	var pos = bullet.global_position
	var rot = bullet.global_rotation
	self.remove_child(bullet)
	get_node("/root/World").add_child(bullet)
	bullet.position = pos
	bullet.rotation = rot
	bullet.shoot(plr_rot, plr_pos)
