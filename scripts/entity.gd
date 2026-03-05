extends Area2D
class_name Entity

var health: int = 10
var attack: int = 3
var defense: int = 0

var knockback_velocity : Vector2 = Vector2.ZERO
var friction : float = 100

func take_damage(amount: int):
	amount -= defense
	
	if health > amount:
		health -= amount
	else:
		health = 0
		queue_free()
		
func apply_knockback(source_position: Vector2, strength: float):
	var push_direction = source_position.direction_to(global_position)
	knockback_velocity = push_direction * strength
