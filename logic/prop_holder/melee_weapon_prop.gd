class_name MeleeWeaponProp extends Prop

@export var damage: float = 10.0
@export var attack_range: float = 1.0

func use_weapon(user, direction):
	print("Melee weapon attack! Damage: %s, Range: %s" % [damage, attack_range])
	# Here you would implement the actual attack logic, 
	# potentially using signals to communicate with the MeleeWeapon scene instance