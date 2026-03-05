extends Entity

const SPEED = 100.0

enum Action{WALKING, IDLE, ATTACKING}

@onready var axe: Area2D = $Axe
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var target : Node2D
var action : Action = Action.IDLE
var is_looking_right := true

func _process(delta: float) -> void:
	_manage_entity_action(delta)
	_manage_sprite_animation()

func _manage_entity_action(delta: float) -> void:
	if target == null:
		action = Action.IDLE
		return
	
	var direction = position.direction_to(target.position)
	if direction != Vector2.ZERO:
		action = Action.WALKING
	
	if direction.x != 0:
		is_looking_right = direction.x > 0
	
	if knockback_velocity.is_zero_approx():
		position += direction * SPEED * delta
	else:
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, friction * delta)
		position += knockback_velocity
	
func _manage_sprite_animation() -> void:
	sprite.flip_h = not is_looking_right
	axe.rotation = 0 if is_looking_right else PI
	
	match action:
		Action.IDLE:
			sprite.play("idle")
		Action.ATTACKING:
			sprite.play("attack")
		Action.WALKING:
			sprite.play("walking")
		_:
			return

func _on_vision_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		target = area

func _on_vision_area_exited(area: Area2D) -> void:
	if area.is_in_group("player"):
		target = null
