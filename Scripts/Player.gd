extends Node3D

var usingL = false
var usingR = false

var blockingL = false
var blockingR = false

var punchSpeed = 1.5

var armLDefPos: Vector3
var armRDefPos: Vector3

func _ready():
    armLDefPos = $ArmL.position
    armRDefPos = $ArmR.position

func _process(_dt):
    var mousePos: Vector2 = get_viewport().get_mouse_position()
    var left: bool = mousePos.x < get_viewport().size.x / 2
    if left:
        if !usingL:
            $ArmL.position = armLDefPos + Vector3(0, 0.1, 0)
        if !usingR:
            $ArmR.position = armRDefPos
    else:
        if !usingR:
            $ArmR.position = armRDefPos + Vector3(0, 0.1, 0)
        if !usingL:
            $ArmL.position = armLDefPos
        
    if Input.is_action_just_pressed("punch") || Input.is_action_just_pressed("block"):
        if left:
            if !usingL:
                usingL = true
                if Input.is_action_just_pressed("punch"):
                    $ArmL.position.z += -1
                    var punchTween: Tween = create_tween()
                    punchTween.tween_interval(1/punchSpeed)
                    punchTween.tween_callback(Callable(self, "ResetArmL"))
                else:
                    blockingL = true
                    $ArmL.position += Vector3(0.3, 0.5, 0)
                    var blockTween: Tween = create_tween()
                    blockTween.tween_interval(1/punchSpeed)
                    blockTween.tween_callback(Callable(self, "ResetArmL"))
        else:
            if !usingR:
                usingR = true
                if Input.is_action_just_pressed("punch"):
                    $ArmR.position.z += -1
                    var punchTween: Tween = create_tween()
                    punchTween.tween_interval(1/punchSpeed)
                    punchTween.tween_callback(Callable(self, "ResetArmR"))
                else:
                    blockingR = true
                    $ArmR.position += Vector3(-0.3, 0.5, 0)
                    var blockTween: Tween = create_tween()
                    blockTween.tween_interval(1/punchSpeed)
                    blockTween.tween_callback(Callable(self, "ResetArmR"))

func ResetArmL():
    $ArmL.position = armLDefPos
    usingL = false
    blockingL = false

func ResetArmR():
    $ArmR.position = armRDefPos
    usingR = false
    blockingR = false