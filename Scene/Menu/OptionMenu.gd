extends Control

var is_paused = 0
var menu_stack = ["res://Scene/Menu/OptionMenu.gd"]
signal sound_has_change
# Called when the node enters the scene tree for the first time.
func _ready():
	hide()

func _process(_delta):
	if (Input.is_action_just_pressed("ui_cancel")):
		toggle_pause()
			

func toggle_pause():
	is_paused += 1
	show()
	if (not (is_paused % 2)):
		hide()
		get_tree().paused = false
				

func _on_button_button_up():
	toggle_pause()


func _on_Main_menu_button_up():
	toggle_pause()
	get_tree().change_scene_to_file("res://Scene/Menu/MainMenu.tscn")


func soundOption():
	print("yolo")


func _on_h_slider_drag_ended(value_changed):
	Config.sound = $CenterContainer.get_node("HSlider").value
	emit_signal("sound_has_change")	

