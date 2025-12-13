extends Node3D

func _ready() -> void:
    if Globals.christmasMode:
        $World/Snow.visible = true
    else:
        $World/Snow.visible = false