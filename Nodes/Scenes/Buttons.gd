extends Button

@export var hoverScale: Vector2 = Vector2(1.1,1.1)
@export var PressedScale: Vector2 = Vector2(0.9,0.9)

@export var disableForWeb: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	focus_mode = FOCUS_NONE
	if (OS.get_name() == "Web" && disableForWeb):
		disabled = true
	mouse_entered.connect(_buttonEnter)
	mouse_exited.connect(_buttonExit)
	focus_exited.connect(_buttonExit)
	pressed.connect(_buttonPressed)
	call_deferred("_init_pivot")
	
func _init_pivot() -> void:
	pivot_offset = size/2.0
	
func _buttonEnter() -> void:
	create_tween().tween_property(self,"scale",hoverScale,0.1).set_trans(Tween.TRANS_SINE) 
	SFXPlayer.ins.PlaySound(7, SFXPlayer.SoundType.SFX, 1.0, (randf() * 0.4) + 0.8)
 
func _buttonExit() -> void:
	create_tween().tween_property(self,"scale",Vector2.ONE,0.1).set_trans(Tween.TRANS_SINE) 

func _buttonPressed() -> void:
	var buttonPressedTween: Tween = create_tween()
	buttonPressedTween.tween_property(self,"scale",PressedScale,0.06).set_trans(Tween.TRANS_SINE) 
	buttonPressedTween.tween_property(self,"scale",hoverScale,0.12).set_trans(Tween.TRANS_SINE)
	SFXPlayer.ins.PlaySound(6, SFXPlayer.SoundType.SFX, 0.6, (randf() * 0.4) + 0.8)
