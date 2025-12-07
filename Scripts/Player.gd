class_name Player extends Node3D

var usingL = false
var usingR = false

var blockingL = false
var blockingR = false

var punchSpeed = 2.5
var punchDamage = 10

var armLDefPos: Vector3
var armRDefPos: Vector3

var stamMax: float = 100
var stamCur: float = 100
var outOfStam: bool = false

var healthMax: float = 100
var healthCur: float = 100

var punchCost: float = 30
var blockCost: float = 13

var recovery: float = 33
var recoverycd: float = 0

var cam: Camera3D
var camForward: Vector3
var camDefPos: Vector3
var camBob: float
var camBobTween: Tween

var hitRecoil: float

@onready var stamBar: ProgressBar = %StamBar
@onready var healthBar: ProgressBar = %HealthBar
@onready var dmgBorder: TextureRect = %DMGBorder
@onready var knockoutBorder: TextureRect = %KnockoutBorder

@export var gloves: Array[Texture]

static var ins: Player

func _init():
	ins = self

func _ready():
	cam = $Cam
	camForward = cam.rotation
	camDefPos = cam.position
	armLDefPos = $ArmL.position
	armRDefPos = $ArmR.position

	knockoutBorder.modulate.a = 0

	stamBar.modulate = Color(1.0, 0.85, 0.0)

	camBobTween = create_tween().set_loops()
	camBobTween.tween_property(self, "camBob", 1.0, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	camBobTween.tween_property(self, "camBob", 0.0, 0.4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	camBobTween.tween_property(self, "camBob", -1.0, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	camBobTween.tween_property(self, "camBob", 0.0, 0.4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)

func CamStuff(_dt: float, mousePos: Vector2):
	var lookOffset = Vector2(mousePos.x / get_viewport().size.x, mousePos.y / get_viewport().size.y)
	lookOffset -= Vector2(.5, .5)
	cam.rotation.y = camForward.y - (lookOffset.x * 0.3)
	cam.rotation.x = camForward.x - (lookOffset.y * 0.3)

	cam.position.y = camDefPos.y + (camBob * 0.01)
	cam.position.z = camDefPos.z + hitRecoil

func KnockoutAnim():
	var knockoutTween: Tween = create_tween()
	knockoutTween.tween_property(knockoutBorder, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _process(_dt):
	recoverycd -= _dt
	if recoverycd < 0:
		stamCur += recovery * _dt
		if stamCur > stamMax:
			stamCur = stamMax
			if outOfStam: 
				outOfStam = false
				stamBar.modulate = Color(1.0, 0.85, 0.0)

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
		
	if left && !usingL:
		if Input.is_action_just_pressed("punch") && !outOfStam:
			var punchTween: Tween = create_tween()
			punchTween.tween_property($ArmL, "position:z", $ArmL.position.z - 1, 1/punchSpeed).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
			punchTween.tween_callback(Callable(self, "ResetArmL"))
			stamCur -= punchCost
			recoverycd = 0.35
			usingL = true
			$ArmL.texture = gloves[1]
		elif Input.is_action_just_pressed("block") && !outOfStam:
			blockingL = true
			$ArmL.position += Vector3(0.3, 0.5, 0)
			var blockTween: Tween = create_tween()
			blockTween.tween_interval(1/punchSpeed)
			blockTween.tween_callback(Callable(self, "ResetArmL"))
			stamCur -= blockCost
			recoverycd = 0.35
			usingL = true
	elif !left && !usingR:
		if Input.is_action_just_pressed("punch") && !outOfStam:
			var punchTween: Tween = create_tween()
			punchTween.tween_property($ArmR, "position:z", $ArmR.position.z - 1, 1/punchSpeed).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
			punchTween.tween_callback(Callable(self, "ResetArmR"))
			stamCur -= punchCost
			recoverycd = 0.35
			usingR = true
			$ArmR.texture = gloves[1]
		elif Input.is_action_just_pressed("block") && !outOfStam:
			blockingR = true
			$ArmR.position += Vector3(-0.3, 0.5, 0)
			var blockTween: Tween = create_tween()
			blockTween.tween_interval(1/punchSpeed)
			blockTween.tween_callback(Callable(self, "ResetArmR"))
			stamCur -= blockCost
			recoverycd = 0.35
			usingR = true

	if stamCur < 0:
		stamCur = 0
		outOfStam = true
		stamBar.modulate = Color(0.5, 0.5, 1.0)

	stamBar.value = stamCur

	CamStuff(_dt, mousePos)

func ResetArmL():
	if !blockingL:
		Enemy.ins.TakeDamage(punchDamage)
	var resetTween: Tween = create_tween()
	resetTween.tween_property($ArmL, "position", armLDefPos, 0.1)
	resetTween.tween_callback(func(): usingL = false)
	resetTween.tween_callback(func(): blockingL = false)
	$ArmL.texture = gloves[0]

func ResetArmR():
	if !blockingR:
		Enemy.ins.TakeDamage(punchDamage)
	var resetTween: Tween = create_tween()
	resetTween.tween_property($ArmR, "position", armRDefPos, 0.1)
	resetTween.tween_callback(func(): usingR = false)
	resetTween.tween_callback(func(): blockingR = false)
	$ArmR.texture = gloves[0]

func TakeDamage(val: float):
	healthCur -= val
	dmgBorder.modulate.a = 1.0
	var dmgFlash: Tween = create_tween()
	dmgFlash.tween_property(dmgBorder, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if healthCur < 0:
		Die()

	hitRecoil = 0.05
	var hitRecoilTween: Tween = create_tween()
	hitRecoilTween.tween_property(self, "hitRecoil", 0.0, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

	healthBar.value = healthCur

func Die():
	pass
