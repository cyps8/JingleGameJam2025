class_name Enemy extends Node3D

enum EnemyType { SLOTH = 0, ELEPHANT = 1, CHEETAH = 2 }

@export var enemyTexture: Texture
@export var armTexture: Texture
@export var punchTexture: Texture

var healthMax: float = 150
var healthCur: float = 150

var punchFrequency: float = 2.0
var punchCD: float = 2.0

var punchDamage: float = 13
var punchCost: float = 25
var left: bool = false

var camBob: float
var camBobTween: Tween

var spriteDefPos: Vector3

var staminaMax: float = 100
var staminaCur: float = 100
var stamRecovery: float = 40

var outOfStam: bool = false

static var ins: Enemy

@onready var healthIcon: Sprite3D = %Health
var defaultHealthIconScale: float
@onready var staminaIcon: Sprite3D = %Stamina
var defaultStaminaIconScale: float
var defaultStaminaIconColor: Color

func _init() -> void:
	ins = self

func _ready() -> void:
	healthCur = healthMax
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
	if outOfStam:
		staminaCur += stamRecovery * _dt
		var stamScale: float = staminaCur / staminaMax
		staminaIcon.scale = Vector3(stamScale * defaultStaminaIconScale, stamScale * defaultStaminaIconScale, stamScale * defaultStaminaIconScale)
		if staminaCur > staminaMax:
			staminaCur = staminaMax
			outOfStam = false
			staminaIcon.modulate = defaultStaminaIconColor
	else:
		punchCD -= _dt
	
	if punchCD < 0:
		punchCD = punchFrequency
		Punch()

func Punch():
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

	arm.texture = punchTexture
	var armDefPos: Vector3 = arm.position
	arm.position += Vector3(0, 0.2, 0)
	
	var punchTween: Tween = create_tween()
	punchTween.tween_property(arm, "position", arm.position + Vector3(punchOffset,0.1,0.8), 0.8).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	punchTween.tween_callback(TryDamage)
	punchTween.tween_property(arm, "position", armDefPos, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	punchTween.tween_callback(func(): arm.texture = armTexture)

func TryDamage():
	if left && !Player.ins.blockingL:
		Player.ins.TakeDamage(punchDamage)
	elif !left && !Player.ins.blockingR:
		Player.ins.TakeDamage(punchDamage)

	staminaCur -= punchCost
	if staminaCur <= 0:
		outOfStam = true
		staminaIcon.modulate = Color(0.5, 0.5, 1.0)

	var stamScale: float = staminaCur / staminaMax
	staminaIcon.scale = Vector3(stamScale * defaultStaminaIconScale, stamScale * defaultStaminaIconScale, stamScale * defaultStaminaIconScale)

func TakeDamage(val: float):
	healthCur -= val
	if healthCur < 0:
		Die()
	var dmgFlash: Tween = create_tween()
	$Sprite.modulate = Color.RED
	$ArmL.modulate = Color.RED
	$ArmR.modulate = Color.RED
	dmgFlash.tween_property($Sprite, "modulate", Color.WHITE, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	dmgFlash.parallel()
	dmgFlash.tween_property($ArmL, "modulate", Color.WHITE, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	dmgFlash.parallel()
	dmgFlash.tween_property($ArmR, "modulate", Color.WHITE, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	var healthScale: float = healthCur / healthMax
	healthIcon.scale = Vector3(healthScale * defaultHealthIconScale, healthScale * defaultHealthIconScale, healthScale * defaultHealthIconScale)

func Die():
	pass