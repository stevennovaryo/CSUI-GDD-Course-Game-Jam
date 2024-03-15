class_name BasicCharacterStats
extends CharacterBody2D

@export var max_hit_point: int = 1000
@export var attack_damage: int = 10
@export var attack_damage_consistency: float = 0.9
@export var is_vulnerable: bool = true
@export var on_hurt_knockback: int = 300

signal hit_point_depleted
signal on_hit(damage: int, direction_vector: Vector2)

var current_hitpoint = max_hit_point

func take_damage(damage: int, direction_vector: Vector2) -> void:
	if is_vulnerable:
		current_hitpoint -= damage
		if current_hitpoint > 0:
			on_hit.emit(damage, direction_vector)
		else:
			hit_point_depleted.emit()
