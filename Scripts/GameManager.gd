class_name GameManager extends Node

static var ins: GameManager

var paused = false

var pauseMenuRef: CanvasLayer

func _init():
	ins = self

func _ready():
	pauseMenuRef = $PauseMenu
	pauseMenuRef.visible = true
	remove_child(pauseMenuRef)
	var delayTween: Tween = create_tween()
	delayTween.tween_callback(Root.ins.HideLoadingScreen).set_delay(0.05)
func _process(_dt):
	if Input.is_action_just_pressed("pause") && !Root.ins.optionsOpen:
		TogglePause()

func TogglePause():
	paused = !paused
	get_tree().paused = paused
	if paused:
		add_child(pauseMenuRef)
	else:
		remove_child(pauseMenuRef)
