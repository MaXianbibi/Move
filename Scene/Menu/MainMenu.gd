extends Control

#var MainScene = preload("res://Scene/MainMenu/MainMenu.tscn").instantiate()

# Called when the node enters the scene tree for the first time.
func _ready():
	$MainMenuMusic.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_button_button_down():
	get_tree().change_scene_to_file("res://Scene/MainScene/MainScene.tscn")


	
