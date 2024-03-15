class_name LightHitBox
extends Area2D

@export var hitbox_damage: int = 250
@onready var the_lamp: TheLamp = get_lamp_parent(self)
var available_light_sources: Array[LightSource]

func _init() -> void:
	monitoring = true
	monitorable = false
	collision_layer = 8
	collision_mask = 4

func get_lamp_parent(node: Node) -> TheLamp:
	while not node is TheLamp:
		node = node.get_parent()
		assert(node.get_parent())
	return node

var rng = RandomNumberGenerator.new()

func get_final_damage(character: BasicCharacterStats):
	return round(rng.randf_range(character.attack_damage_consistency, 1) * character.attack_damage * hitbox_damage) 

func add_to_available_light_sources(light_hurt_box: LightHurtBox) -> void:
	var light_source = light_hurt_box.get_light_source_parent(light_hurt_box)
	if not light_source in available_light_sources:
		available_light_sources.append(light_source)

func remove_from_available_light_sources(light_hurt_box: LightHurtBox) -> void:
	var light_source = light_hurt_box.get_light_source_parent(light_hurt_box)
	if light_source in available_light_sources:
		available_light_sources.erase(light_source)

func _process(delta: float) -> void:
	while not available_light_sources.is_empty() and available_light_sources.front().light_hit_point <= 0:
		available_light_sources.pop_front()
	if not available_light_sources.is_empty():
		the_lamp.absorb_light(available_light_sources.front(), round(hitbox_damage * delta))

func _ready() -> void:
	connect("area_entered", add_to_available_light_sources)
	connect("area_exited", remove_from_available_light_sources)
	pass

