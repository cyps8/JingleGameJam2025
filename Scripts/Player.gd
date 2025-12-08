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

var biteCd: float = 0
var biteCdMax: float = 6
var biteDamage: float = 20
var biteHeal: float = 15
var biteCost: float = 30

var screechCd: float = 0
var screechCdMax: float = 12

var beatCd: float = 0
var beatCdMax: float = 16
var enhancedStamina: float = 0

@onready var stamBar: ProgressBar = %StamBar
@onready var healthBar: ProgressBar = %HealthBar
@onready var dmgBorder: TextureRect = %DMGBorder
@onready var blockBorder: TextureRect = %BlockBorder
@onready var knockoutBorder: TextureRect = %KnockoutBorder
@onready var biteAbility: TextureProgressBar = %BiteCD
@onready var screechAbility: TextureProgressBar = %ScreechCD
@onready var beatAbility: TextureProgressBar = %BeatCD

@onready var lowerTeeth: Sprite3D = %LowerTeeth
@onready var upperTeeth: Sprite3D = %UpperTeeth

@export var gloves: Array[Texture]

static var ins: Player

func _init():
	ins = self

func _ready():
	if Globals.biteUnlocked:
		biteAbility.visible = true
	
	if Globals.screechUnlocked:
		screechAbility.visible = true

	if Globals.beatUnlocked:
		beatAbility.visible = true

	if Globals.tailUnlocked:
		punchSpeed *= 1.3
		stamMax *= 1.2
		stamBar.max_value = stamMax
		stamCur = stamMax

	if Globals.muscleUnlocked:
		punchDamage *= 1.3
		punchCost *= 0.9

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

	var mousePos: Vector2 = get_viewport().get_mouse_position()
	lastSide = mousePos.x < get_viewport().size.x / 2

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

var lastSide: bool = false

func _process(_dt):
	recoverycd -= _dt

	if enhancedStamina > 0:
		stamCur += recovery * _dt * 3
		enhancedStamina -= _dt
		if enhancedStamina < 0:
			enhancedStamina = 0
			stamBar.modulate = Color(1.0, 0.85, 0.0)
		else:
			stamBar.modulate = Color(1.0, 0.97, 0.7)

	if recoverycd < 0:
		stamCur += recovery * _dt
		if stamCur > stamMax:
			stamCur = stamMax
			if outOfStam: 
				outOfStam = false
				stamBar.modulate = Color(1.0, 0.85, 0.0)

	biteCd -= _dt
	biteAbility.value = (biteCdMax - biteCd) / biteCdMax
	if Input.is_action_just_pressed("bite") && !outOfStam && biteCd < 0 && Globals.biteUnlocked:
		Bite()

	screechCd -= _dt
	screechAbility.value = (screechCdMax - screechCd) / screechCdMax
	if Input.is_action_just_pressed("screech") && !outOfStam && screechCd < 0 && Globals.screechUnlocked:
		Screech()

	beatCd -= _dt
	beatAbility.value = (beatCdMax - beatCd) / beatCdMax
	if Input.is_action_just_pressed("beat") && !outOfStam && beatCd < 0 && Globals.beatUnlocked && !usingL && !usingR:
		Beat()

	var mousePos: Vector2 = get_viewport().get_mouse_position()
	var left: bool = mousePos.x < get_viewport().size.x / 2

	if left != lastSide:
		SFXPlayer.ins.PlaySound(7, SFXPlayer.SoundType.SFX, 1.0, (randf() * 0.4) + 0.8)
		lastSide = left

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
			punchTween.parallel()
			punchTween.tween_property($ArmL, "position:x", $ArmL.position.x + 0.5, 1/punchSpeed).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
			punchTween.parallel()
			punchTween.tween_property($ArmL, "position:y", $ArmL.position.y + 0.2, 1/punchSpeed)
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
			punchTween.parallel()
			punchTween.tween_property($ArmR, "position:x", $ArmR.position.x - 0.5, 1/punchSpeed).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
			punchTween.parallel()
			punchTween.tween_property($ArmR, "position:y", $ArmR.position.y + 0.2, 1/punchSpeed)
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

func Bite():
	stamCur -= biteCost
	recoverycd = 0.35
	biteCd = biteCdMax
	var biteTween: Tween = create_tween()
	lowerTeeth.position.y = -0.8
	upperTeeth.position.y = 0.8
	biteTween.tween_property(lowerTeeth, "position:y", -0.2, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	biteTween.parallel()
	biteTween.tween_property(upperTeeth, "position:y", 0.2, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	biteTween.parallel()
	biteTween.tween_property(lowerTeeth, "modulate:a", 1.0, 0.4)
	biteTween.parallel()
	biteTween.tween_property(upperTeeth, "modulate:a", 1.0, 0.4)
	biteTween.tween_callback(func(): Enemy.ins.TakeDamage(biteDamage))
	biteTween.tween_callback(func(): HealDamage(biteHeal))
	biteTween.tween_interval(0.2)
	biteTween.tween_property(lowerTeeth, "modulate:a", 0.0, 0.2)
	biteTween.parallel()
	biteTween.tween_property(upperTeeth, "modulate:a", 0.0, 0.2)

func Screech():
	screechCd = screechCdMax
	Enemy.ins.Stunned()

func Beat():
	usingL = true
	usingR = true
	beatCd = beatCdMax
	var beatTween: Tween = create_tween()
	beatTween.tween_property($ArmL, "position:x", $ArmL.position.x + 0.3, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	beatTween.parallel()
	beatTween.tween_property($ArmR, "position:x", $ArmR.position.x - 0.3, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	beatTween.parallel()
	beatTween.tween_property($ArmL, "position:y", $ArmL.position.y - 0.2, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	beatTween.parallel()
	beatTween.tween_property($ArmR, "position:y", $ArmR.position.y - 0.2, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	for i in range(4):
		beatTween.tween_property($ArmL, "position:y", $ArmL.position.y - 0.2, 0.07).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		beatTween.parallel()
		beatTween.tween_property($ArmR, "position:y", $ArmR.position.y - 0.5, 0.07).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		beatTween.tween_property($ArmL, "position:y", $ArmL.position.y - 0.5, 0.07).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		beatTween.parallel()
		beatTween.tween_property($ArmR, "position:y", $ArmR.position.y - 0.2, 0.07).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	beatTween.tween_property($ArmR, "position", armRDefPos, 0.1)
	beatTween.parallel()
	beatTween.tween_property($ArmR, "position", armRDefPos, 0.1)
	beatTween.tween_callback(func(): enhancedStamina = 4.0)
	beatTween.tween_callback(func(): usingR = false)
	beatTween.tween_callback(func(): usingL = false)

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
	if Globals.furUnlocked:
		healthCur -= val * 0.75
	else:
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

	SFXPlayer.ins.PlaySound(3, SFXPlayer.SoundType.SFX, 1.0, (randf() * 0.4) + 0.8)
	SFXPlayer.ins.PlaySound(6, SFXPlayer.SoundType.SFX, 0.8, (randf() * 0.2) + 0.9)

func HealDamage(val):
	healthCur += val
	healthBar.value = healthCur

	if healthCur > healthMax:
		healthCur = healthMax

func Block():
	if Globals.furUnlocked:
		stamCur += 5
	blockBorder.modulate.a = 1.0
	var blockFlash: Tween = create_tween()
	blockFlash.tween_property(blockBorder, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	hitRecoil = 0.02
	var hitRecoilTween: Tween = create_tween()
	hitRecoilTween.tween_property(self, "hitRecoil", 0.0, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

func Die():
	if Globals.lossCount < 4:
		Root.ins.ChangeScene(Root.Scene.ABILITY_SELECT)
	else:
		Root.ins.ChangeScene(Root.Scene.LOSE)
