extends Node

var lossCount: int = 0
var randomInt: Array[int] = [0,1,2,3,4,5]

var currentOpponent: Enemy.EnemyType = Enemy.EnemyType.SLOTH

var biteUnlocked: bool = false
var screechUnlocked: bool = false
var beatUnlocked: bool = false
var furUnlocked: bool = false
var muscleUnlocked: bool = false
var tailUnlocked: bool = false

var justUpgraded: bool = false

var hardMode: bool = false
var hardUnlocked: bool = false

var christmasMode: bool = false