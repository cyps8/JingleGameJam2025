extends Button

@export var hoverScale: Vector2 = Vector2(1.1,1.1)
@export var PressedScale: Vector2 = Vector2(0.9,0.9)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_entered.connect(_buttonEnter)
	mouse_exited.connect(_buttonExit)
	focus_exited.connect(_buttonExit)
	pressed.connect(_buttonPressed)
	call_deferred("_init_pivot")
	
func _init_pivot() -> void:
	pivot_offset = size/2.0
	
func _buttonEnter() -> void:
	create_tween().tween_property(self,"scale",hoverScale,0.1).set_trans(Tween.TRANS_SINE) 
 
func _buttonExit() -> void:
	create_tween().tween_property(self,"scale",Vector2.ONE,0.1).set_trans(Tween.TRANS_SINE) 

func _buttonPressed() -> void:
	var buttonPressedTween: Tween = create_tween()
	buttonPressedTween.tween_property(self,"scale",PressedScale,0.06).set_trans(Tween.TRANS_SINE) 
	buttonPressedTween.tween_property(self,"scale",hoverScale,0.12).set_trans(Tween.TRANS_SINE) 
