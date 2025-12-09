class_name Enemy extends Node3D

enum EnemyType { SLOTH = 0, ELEPHANT = 1, CHEETAH = 2 }

var enemyType: EnemyType

@export var enemyTexture: Array[Texture]
@export var armTexture: Array[Texture]
@export var punchTexture: Array[Texture]

var healthMax: Array[float] = ([150, 280, 220])
var healthCur: float = 150

var punchFrequency: Array[float] = ([2.0, 1.5, 0.9])
var punchCD: float = 1.5
var punchSpeed: Array[float] = ([0.8, 0.7, 0.55])

var punchDamage: Array[float] = ([13, 25, 20])
var punchCost: Array[float] = ([25, 12.5, 20])
var left: bool = false

var camBob: float
var camBobTween: Tween

var spriteDefPos: Vector3

var staminaMax: float = 100
var staminaCur: float = 100
var stamRecovery: Array[float] = ([40, 16, 80])

var outOfStam: bool = false

var lastBlock: int = 0

var stunned: float = 0

var dead: bool = false

var intro: bool = true

static var ins: Enemy

@onready var healthIcon: Sprite3D = %Health
var defaultHealthIconScale: float
@onready var staminaIcon: Sprite3D = %Stamina
var defaultStaminaIconScale: float
var defaultStaminaIconColor: Color

func _init() -> void:
	ins = self

func _ready() -> void:
	enemyType = Globals.currentOpponent

	$Sprite.texture = enemyTexture[enemyType]
	$ArmL.texture = armTexture[enemyType]
	$ArmR.texture = armTexture[enemyType]

	if enemyType == EnemyType.ELEPHANT:
		healthIcon.position.y += 0.3
		staminaIcon.position.y += 0.3
		%Dazed.position.y += 0.3
		$Sprite.position.y += 0.25
		$ArmL.position += Vector3(-0.1, 0.25, 0.1)
		$ArmR.position += Vector3(0.1, 0.25, 0.1)
		var s = $Sprite.scale.x * 1.2
		$Sprite.scale = Vector3(s, s, s)
		s = $ArmL.scale.x * 1.2
		$ArmL.scale = Vector3(s, s, s)
		$ArmR.scale = Vector3(s, s, s)

	if enemyType == EnemyType.CHEETAH:
		healthIcon.position.y += 0.1
		staminaIcon.position.y += 0.1
		$Sprite.position.y += 0.1
		$ArmL.position += Vector3(0, 0.2, 0.05)
		$ArmR.position += Vector3(0, 0.2, 0.05)
		%Dazed.position.y += 0.1

	healthCur = healthMax[enemyType]
	staminaCur = staminaMax

	spriteDefPos = $Sprite.position
	camBobTween = create_tween().set_loops()
	camBobTween.tween_property(self, "camBob", 1.0, 0.275).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	camBobTween.tween_property(self, "camBob", 0.0, 0.275).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	camBobTween.tween_property(self, "camBob", -1.0, 0.275).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	camBobTween.tween_property(self, "camBob", 0.0, 0.275).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)

	defaultHealthIconScale = healthIcon.scale.x
	defaultStaminaIconScale = staminaIcon.scale.x
	defaultStaminaIconColor = staminaIcon.modulate

func _process(_dt: float):
	$Sprite.position.y = spriteDefPos.y + ((camBob - 0.5) * 0.01)

	if intro:
		return

	if stunned > 0:
		stunned -= _dt
		if stunned <= 0:
			%Dazed.visible = false
		return

	if outOfStam:
		staminaCur += stamRecovery[enemyType] * _dt
		var stamScale: float = staminaCur / staminaMax
		staminaIcon.scale = Vector3(stamScale * defaultStaminaIconScale, stamScale * defaultStaminaIconScale, stamScale * defaultStaminaIconScale)
		if staminaCur > staminaMax:
			staminaCur = staminaMax
			outOfStam = false
			staminaIcon.modulate = defaultStaminaIconColor
	else:
		punchCD -= _dt
	
	if punchCD < 0:
		punchCD = punchFrequency[enemyType]
		Punch()

func Punch():
	if Player.ins.dead  || dead:
		return
	var arm: Sprite3D
	var punchOffset: float = 0
	if randf() < 0.5:
		arm = $ArmL
		left = true
		punchOffset = 0.1
	else:
		arm = $ArmR
		left = false
		punchOffset = -0.1

	arm.texture = punchTexture[enemyType]
	var armDefPos: Vector3 = arm.position
	arm.position += Vector3(0, 0.2, 0)
	
	var punchTween: Tween = create_tween()
	punchTween.tween_property(arm, "position", arm.position + Vector3(punchOffset,0.1,1.0), punchSpeed[enemyType]).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	punchTween.tween_callback(TryDamage)
	punchTween.tween_property(arm, "position", armDefPos, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	punchTween.tween_callback(func(): arm.texture = armTexture[enemyType])

func TryDamage():
	if left && !Player.ins.blockingL:
		Player.ins.TakeDamage(punchDamage[enemyType])
	elif !left && !Player.ins.blockingR:
		Player.ins.TakeDamage(punchDamage[enemyType])
	else:
		if lastBlock == 0:
			lastBlock = 1
		else: 
			lastBlock = 0
		SFXPlayer.ins.PlaySound(4 + lastBlock, SFXPlayer.SoundType.SFX, 1.0, (randf() * 0.2) + 0.9)
		Player.ins.Block()

	staminaCur -= punchCost[enemyType]
	if staminaCur <= 0:
		outOfStam = true
		staminaIcon.modulate = Color(0.5, 0.5, 1.0)

	var stamScale: float = staminaCur / staminaMax
	staminaIcon.scale = Vector3(stamScale * defaultStaminaIconScale, stamScale * defaultStaminaIconScale, stamScale * defaultStaminaIconScale)

func TakeDamage(val: float):
	if Player.ins.dead  || dead:
		return
	healthCur -= val
	if healthCur <= 0:
		healthCur = 0
		Die()
	var dmgFlash: Tween = create_tween()
	$Sprite.modulate = Color.RED
	$ArmL.modulate = Color.RED
	$ArmR.modulate = Color.RED
	dmgFlash.tween_property($Sprite, "modulate", Color.WHITE, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	dmgFlash.parallel()
	dmgFlash.tween_property($ArmL, "modulate", Color.WHITE, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	dmgFlash.parallel()
	dmgFlash.tween_property($ArmR, "modulate", Color.WHITE, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	var healthScale: float = healthCur / healthMax[enemyType]
	healthIcon.scale = Vector3(healthScale * defaultHealthIconScale, healthScale * defaultHealthIconScale, healthScale * defaultHealthIconScale)

	if enemyType == EnemyType.SLOTH:
		SFXPlayer.ins.PlaySound(randi_range(0, 2), SFXPlayer.SoundType.SFX, 1.0, (randf() * 0.2) + 0.9)
	elif enemyType == EnemyType.ELEPHANT:
		SFXPlayer.ins.PlaySound(randi_range(13, 14), SFXPlayer.SoundType.SFX, 1.0, (randf() * 0.2) + 0.9)
	elif enemyType == EnemyType.CHEETAH:
		SFXPlayer.ins.PlaySound(randi_range(15, 17), SFXPlayer.SoundType.SFX, 1.0, (randf() * 0.2) + 0.9)
	SFXPlayer.ins.PlaySound(6, SFXPlayer.SoundType.SFX, 0.6, (randf() * 0.2) + 0.9)

func Stunned():
	%Dazed.visible = true
	stunned = 3.0

func Die():
	dead = true
	SFXPlayer.ins.PlaySound(8, SFXPlayer.SoundType.SFX)
	var dyingTween: Tween = create_tween()
	dyingTween.tween_property(self, "rotation:x", -90.0, 1.5).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN)
	dyingTween.parallel()
	dyingTween.tween_property(self, "position:z", -1.0, 1.5).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	dyingTween.parallel()
	dyingTween.tween_property(self, "position:y", -1.0, 1.5).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN)
	dyingTween.tween_interval(0.5)
	dyingTween.tween_callback(func(): DeathOver())

func DeathOver():
	if enemyType == EnemyType.SLOTH:
		Globals.currentOpponent = Enemy.EnemyType.ELEPHANT
		Root.ins.ChangeScene(Root.Scene.GAME)
	elif enemyType == EnemyType.ELEPHANT:
		Globals.currentOpponent = Enemy.EnemyType.CHEETAH
		Root.ins.ChangeScene(Root.Scene.GAME)
	elif enemyType == EnemyType.CHEETAH:
		Player.ins.Win()