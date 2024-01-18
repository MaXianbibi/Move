#MainScene.gd
extends Node

var mob = preload("res://Scene/Mob/mob.tscn")

enum State {Chilling, Running, Attack, Dead}
enum Music { Chill, Battle }
#var music = Music.Chill
var currentMusic
var music
var chillMusic
var fightMusic
var is_paused = false
signal paused




func _unhandled_input(event):
	if (event.is_action_pressed("ui_cancel")):
		var is_paused = get_tree().paused
		get_tree().paused = !is_paused
	

# Called when the node enters the scene tree for the first time.
func _ready():
	chillMusic = $BackgroundMusicChill
	fightMusic = $BackgroundMusicFight
	currentMusic = chillMusic
	music = chillMusic
	spawn_enemy()
	spawn_enemy()
	spawn_enemy()
	spawn_enemy()
	
	for mobSignal in get_tree().get_nodes_in_group("MobsNode"):
		var callable = Callable(self, "_on_player_detected")
		mobSignal.connect("player_detected", callable)
		mobSignal.passive_mode.connect($Player.mob_is_chilling)
	
	#$BackgroundMusic.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):		
	$Camera2D.set_position($Player.get_position());
	if (currentMusic != music):
		if (music == fightMusic):
			switchMusic(chillMusic, fightMusic)
		else:
			switchMusic(fightMusic, chillMusic)
	if ($Player.n_enemy == 0):
		music = chillMusic
	
func spawn_enemy():
	var position = Vector2(randf_range(-200, 200), randf_range(-200, 200))
	var enemy = mob.instantiate()
	enemy.set_position(position)
	add_child(enemy)

func _on_player_detected():
	var mobs = get_tree().get_nodes_in_group("MobsNode")
	$Player.n_enemy = mobs.size()
	for mobSignal in mobs:
		mobSignal.player_is_detected()
		music = fightMusic
			
func switchMusic(current, next):
		currentMusic = music
		var tween = get_tree().create_tween()
		tween.finished.connect(tweenfinished)
		tween.tween_property(current, "volume_db", -80, 1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC)

func tweenfinished():
	var tween = get_tree().create_tween()
	tween.tween_property(currentMusic, "volume_db", Config.sound, 1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC)
	currentMusic.play(0.0)
	
func _on_player_has_take_demage(dmg):
	var tween = get_tree().create_tween()
	tween.tween_property($Camera2D, "offset", Vector2(1, 0), 0.1)
	tween.tween_property($Camera2D, "offset", Vector2(-1, 0), 0.1)
	tween.tween_property($Camera2D, "offset", Vector2(0, 0), 0.1)

func free_mob():
	for mobSignal in get_tree().get_nodes_in_group("MobsNode"):
		mobSignal.queue_free()
		
		
func change_to_main_menu():
		get_tree().change_scene_to_file("res://Scene/MainMenu/MainMenu.tscn")


func _on_option_menu_sound_has_change():
	currentMusic.set_volume_db(Config.sound)
	print(Config.sound)
