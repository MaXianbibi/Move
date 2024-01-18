# Mob.gd
extends Node2D

var speed = 25
var player
enum State {Chilling, Running, Attack, Dead}
var mobState = State.Chilling
var mobDirChilling
var target_angle = 0.0  # Angle cible pour l'interpolation
var rotation_speed_chilling = 1.0
var rotation_speed_running = 5.0
var health = 3
var is_able_to_attack = true
var direction_to_attack

signal player_detected
signal passive_mode

func _ready():
	var players = get_tree().get_nodes_in_group("player")
	mobDirChilling = Vector2(randf_range(0, 50), randf_range(0, 50))
	if players.size() > 0:
		player = players[0]
	$AnimatedSprite2D.play("Walk")


func _process(delta):
	match mobState:
		State.Chilling:
			chillingAction(delta)
		State.Running:
			runAfterPlayer(delta)
		State.Attack:
			attackAction(delta, direction_to_attack)
		State.Dead:
			$AnimatedSprite2D.play("Die")
			
func runAfterPlayer(delta):
	if (player):
		var direction = self.get_position().direction_to(player.get_position())
		#var angle = atan2(direction.y, direction.x)
		#$Vision.set_rotation(angle)
		
		var angle = atan2(direction.y, direction.x)	
		var new_angle = lerp_angle($Vision.get_rotation(), angle, rotation_speed_running * delta)
		$Vision.set_rotation(new_angle)
		
		self.set_position(self.get_position() + (direction * speed * delta))
		if ( direction.x < 0):
			$AnimatedSprite2D.set_flip_h(true)
		elif ($AnimatedSprite2D.is_flipped_h()):
			$AnimatedSprite2D.set_flip_h(false)
		
		if (self.get_position().distance_squared_to(player.get_position()) < 5000 and is_able_to_attack):
			$AttackMode.start()	
			mobState = State.Attack
			direction_to_attack = direction

func _on_vision_area_entered(area):
	var nodeParent = area.get_parent()
	if nodeParent == null:
		return
	if (nodeParent.is_in_group("player")):
		emit_signal("player_detected")
		player_is_detected()
		
func player_is_detected():
	if (mobState == State.Chilling):
		mobState = State.Running
		$IsHeStillThere.start(5.0)

		
func _on_vision_area_exited(_area):
	pass
	#var nodeParent = area.get_parent()
	#if nodeParent == null:
		#return
	#if (nodeParent.is_in_group("player")):
		#if (mobState != State.Attack):
			#mobState = State.Chilling
			#$AnimatedSprite2D.set_modulate("ffffff")	

	
func chillingAction(delta):	
	var direction = self.get_position().direction_to(mobDirChilling)
	var angle = atan2(direction.y, direction.x)	
	var new_angle = lerp_angle($Vision.get_rotation(), angle, rotation_speed_chilling * delta)
	$Vision.set_rotation(new_angle)
	self.set_position(self.get_position() + (direction * speed * delta * 0.75))
	
	if ( direction.x < 0):
		$AnimatedSprite2D.set_flip_h(true)
	elif ($AnimatedSprite2D.is_flipped_h()):
		$AnimatedSprite2D.set_flip_h(false)
	if self.global_position.distance_to(mobDirChilling) < 1: # 10 est un seuil, ajustez-le selon vos besoins
		mobDirChilling = Vector2(randf_range(-100, 100), randf_range(0, 50))  # Générer une nouvelle position aléatoire


static func lerp_angle(from, to, weight):
	var difference = fmod(to - from + PI, 2 * PI) - PI
	return from + difference * weight

func take_demage(angle):
	if mobState == State.Attack:
		$AttackMode.emit_signal("timeout")
		$AttackMode.stop()
	
	var knockback_distance = 100  
	var direction = Vector2(cos(angle), sin(angle))
	var target_position = self.global_position + direction.normalized() * knockback_distance
	var tween = get_tree().create_tween()
	health -= 1
	tween.tween_property(self, "global_position", target_position, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC  )
	mobState = State.Running
	is_able_to_attack = false
	
	if (health <= 0):
		mobState = State.Dead
		
func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "Die":
		passive_mode.emit()		
		self.queue_free()
		
func attackAction(delta, direction):
	var angle = atan2(direction.y, direction.x)	
	var new_angle = lerp_angle($Vision.get_rotation(), angle, rotation_speed_running * delta)
	$Vision.set_rotation(new_angle)
	$IsHeStillThere.start(5.0)	
	if ( direction.x < 0):
		$AnimatedSprite2D.set_flip_h(true)
	elif ($AnimatedSprite2D.is_flipped_h()):
		$AnimatedSprite2D.set_flip_h(false)
	
	$AnimatedSprite2D.set_modulate("ff6352")
	$AnimatedSprite2D.play("Jump")
	self.set_position(self.get_position() + (direction * speed * 10 * delta))

func _on_attack_timer_timeout():
	is_able_to_attack = true


func _on_attack_mode_timeout():
	$AnimatedSprite2D.set_modulate("ffffff")
	$AttackTimer.start(2.0)
	is_able_to_attack = false
	$AnimatedSprite2D.play("Walk")
	mobState = State.Running
	
func set_state(state):
	mobState = state

func _on_is_he_still_there_timeout():
	var entities = $Vision.get_overlapping_areas()
	for entity in entities:
		if (entity.get_parent().is_in_group("player")):
			emit_signal("player_detected")
			$IsHeStillThere.start(5.0)
			return
	mobState = State.Chilling
	passive_mode.emit()
	$IsHeStillThere.stop()
	
