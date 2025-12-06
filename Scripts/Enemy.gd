class_name Enemy extends Node3D

var healthMax: float = 100
var healthCur: float = 100

var punchFrequency: float = 2.0
var punchCD: float = 2.0

var punchDamage: float = 10
var left: bool = false

var camBob: float
var camBobTween: Tween

var spriteDefPos: Vector3

static var ins: Enemy

func _init() -> void:
	ins = self

func _ready() -> void:
	spriteDefPos = $Sprite.position
	camBobTween = create_tween().set_loops()
	camBobTween.tween_property(self, "camBob", 1.0, 0.275).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	camBobTween.tween_property(self, "camBob", 0.0, 0.275).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	camBobTween.tween_property(self, "camBob", -1.0, 0.275).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	camBobTween.tween_property(self, "camBob", 0.0, 0.275).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)

func _process(_dt: float):
	$Sprite.position.y = spriteDefPos.y + ((camBob - 0.5) * 0.01)
	punchCD -= _dt
	if punchCD < 0:
		punchCD = punchFrequency
		Punch()

func Punch():
	var arm: Sprite3D
	if randf() < 0.5:
		arm = $ArmL
		left = true
	else:
		arm = $ArmR
		left = false

	var armDefPos: Vector3 = arm.position
	
	var punchTween: Tween = create_tween()
	punchTween.tween_property(arm, "position", arm.position + Vector3(0,0.2,0.5), 0.8).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	punchTween.tween_callback(TryDamage)
	punchTween.tween_property(arm, "position", armDefPos, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func TryDamage():
	if left && !Player.ins.blockingL:
		Player.ins.TakeDamage(punchDamage)
	elif !left && !Player.ins.blockingR:
		Player.ins.TakeDamage(punchDamage)

func TakeDamage(val: float):
	healthCur -= val
	if healthCur < 0:
		Die()
	var dmgFlash: Tween = create_tween()
	$Sprite.modulate = Color.RED
	dmgFlash.tween_property($Sprite, "modulate", Color.WHITE, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func Die():
	pass