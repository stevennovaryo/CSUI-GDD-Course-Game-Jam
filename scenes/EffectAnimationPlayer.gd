extends AnimationPlayer
class_name EffectAnimationPlayer

var timer: Timer = Timer.new()

signal on_effect_stop(effect: StringName)

func _ready() -> void:
	add_child(timer)
	timer.connect("timeout", on_stop)

var _current_effect: StringName

func play_effect(duration: float, name: StringName, custom_blend: float = -1, custom_speed: float = 1.0, from_end: bool = false) -> void:
	_current_effect = name
	timer.start(duration)
	play(name, custom_blend, custom_speed, from_end)

func on_stop():
	play("RESET")
	on_effect_stop.emit(_current_effect)
