extends Entity


const SPEED = 300.0
const MAX_COMBOS: int = 2


@onready var invincibility: Timer = $Invincibility

@onready var self_collision: CollisionShape2D = $SelfCollision

@onready var sword: Area2D = $Sword
@onready var sword_hit_box: CollisionShape2D = $Sword/HitBox
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var combo_step : int = 0
var velocity : Vector2 = Vector2.ZERO
var is_attacking := false
var is_invincible := false

func _ready() -> void:
	health = 10
	defense = 10

func _process(delta: float) -> void:
	_manage_player_action(delta)
	_manage_sprite_animation()
	
func _manage_player_action(delta: float) -> void:
	if is_attacking:
		return
	
	if Input.is_action_just_pressed("ui_attack"):
		is_attacking = true
		velocity = Vector2.ZERO
		return
	
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	
	if knockback_velocity.is_zero_approx():
		velocity = direction * SPEED * delta
		position += velocity
	else:
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, friction * delta)
		position += knockback_velocity
	
func _manage_sprite_animation() -> void:
	if is_attacking:
		if sprite.animation.begins_with("attack"):
			return
		
		sprite.play("attack_" + str(combo_step))
		combo_step = (combo_step + 1) % MAX_COMBOS
		return
	
	if not velocity.is_zero_approx():
		if velocity.x != 0:
			sprite.flip_h = velocity.x < 0
			sword_hit_box.position.x = (-1 if velocity.x < 0 else 1) * abs(sword_hit_box.position.x)
		
		sprite.play("walking")
		return
		
	sprite.play("idle")
	
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		apply_knockback(area.position, 20)
		self_collision.disabled = true
		invincibility.start()
		take_damage(1)
		
func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation.begins_with("attack"):
		is_attacking = false

func _on_animated_sprite_2d_frame_changed() -> void:
	if sprite == null:
		return
	
	if sprite.animation.begins_with("attack"):
		sword_hit_box.disabled = sprite.frame not in [3,4]

func _on_invincibility_timeout() -> void:
	self_collision.disabled = false

func _on_sword_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		var enemy := area as Entity
		enemy.take_damage(attack)
		enemy.apply_knockback(sword.global_position, 20)
