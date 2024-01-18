#UiScript.gd
extends CanvasLayer

#var player = preload("res://Scene/Player/player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
	#
	#var callable = Callable(self, "_on_player_detected")
	#player.connect("player_detected", callable)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_player_has_take_demage(dmg):
	var progressBar = self.get_node("Control/ProgressBar")
	progressBar.set_value_no_signal(progressBar.get_value() - dmg)

