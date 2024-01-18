extends Node2D

@export var is_crouch = false
@export var speed = 100

var is_attacking = false
signal has_take_demage(dmg)
var n_enemy = 0
enum dangerLevel { safe, trouble }
var is_blocking = false
var is_rolling = false


func _ready():
	$AnimatedSprite2D.play("Stand")
	
	
func _process(delta):
	var velocity = Vector2()
	var is_moving = false
	if is_attacking:
		return
	if is_blocking:
		return
	if (Input.is_action_pressed("move_right")):
		is_crouch = false
		is_moving = true
		if ($AnimatedSprite2D.flip_h):
			turn_h()		
		start_running()
		velocity += Vector2(1, 0)

	if (Input.is_action_pressed("move_left")):
		is_moving = true
		is_crouch = false
		if (!$AnimatedSprite2D.flip_h):
			turn_h()
		start_running()
		velocity += Vector2(-1, 0)
		
	if (Input.is_action_pressed("move_up")):
		is_moving = true
		is_crouch = false
		start_running()
		velocity += Vector2(0, -1)
		
	if (Input.is_action_pressed("move_down")):
		is_moving = true
		is_crouch = false
		start_running()
		velocity += Vector2(0, 1)

	if (Input.is_action_just_pressed("left_attack")):
		is_attacking = true
		$AttackSword.play()
		if ($AnimatedSprite2D.flip_h):
			$Attack.set_scale(Vector2(-1, 1))
		elif !$AnimatedSprite2D.flip_h and $Attack.get_scale() != Vector2(1, 1):
			$Attack.set_scale(Vector2(1, 1))
		$AnimatedSprite2D.play("Attack")
		$Attack.set_monitoring(true)
		return
	if (Input.is_action_just_pressed("block")):
		$AnimatedSprite2D.play("block")
		is_blocking = true
		$blockTimer.start()
		
	if (Input.is_action_just_pressed("rolls")):
		$AnimatedSprite2D.play("Roll")
		is_rolling = true
		speed = 300
		$BodyArea.set_monitoring(false)
		$RollTimer.start()
		
	if (Input.is_action_just_pressed("crouch")):
		is_crouch = !is_crouch
		if (is_crouch):
			$AnimatedSprite2D.play("Crouch")
		else:
			$AnimatedSprite2D.play("Stand")
	if (!is_moving and !is_crouch and !is_blocking and !is_rolling):
		$AnimatedSprite2D.play("Stand")
	
	velocity = velocity.normalized() * speed * delta
	self.set_position( self.get_position() + velocity)
	
func turn_h():
	$AnimatedSprite2D.set_flip_h(!$AnimatedSprite2D.flip_h)

func start_running():
	if not is_rolling:	
		if not $RunningSound.is_playing():
			$RunningSound.play()
		elif $RunningSound.get_playback_position() > 0.5:
			$RunningSound.stop()
		$AnimatedSprite2D.play("Run")
		
func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "Attack":
		is_attacking = false
		$Attack.set_monitoring(false)

func get_angle_to_enemy(player_position, enemy_position):
	var direction = enemy_position - player_position
	var angle = atan2(direction.y, direction.x)
	return angle

func _on_attack_area_entered(area):
	if area.is_in_group("Mobs"):
		var mob = area.get_parent()
		var player_position = self.get_position()
		var mob_position = mob.get_position()
		var angle_to_enemy = get_angle_to_enemy(player_position, mob_position)
		mob.take_demage(angle_to_enemy)

func _on_body_area_area_entered(area):
	if area.is_in_group("Mobs"):
		if (is_blocking):
			$BlockingSound.play()
			
		else:
			take_demage(12)

func take_demage(dmg):
	emit_signal("has_take_demage", dmg)
	$TakeDemageSound.play()
	
func mob_is_chilling():
	n_enemy -= 1
	


func _on_block_timer_timeout():
	is_blocking = false


func _on_roll_timer_timeout():
	is_rolling = false
	speed = 100
	$BodyArea.set_monitoring(true)
	
