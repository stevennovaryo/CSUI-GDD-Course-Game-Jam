extends Node2D
class_name LightSource

@export var light_max_hit_point: float = 100
var light_hit_point: float = light_max_hit_point
@export var light_minimum_energy: float = 0.9
@export var light_minimum_texture_scale: float = 0

signal on_hit(energy: float, texture_scale: float)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# return total dmg taken
func take_damage(damage: int) -> int:
	var damage_taken = min(light_hit_point, damage)
	light_hit_point -= damage_taken
	on_hit.emit(light_minimum_energy + (1 - light_minimum_energy) * (light_hit_point / light_max_hit_point), light_minimum_texture_scale + (1 - light_minimum_texture_scale) * (light_hit_point / light_max_hit_point))
	return damage_taken	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
