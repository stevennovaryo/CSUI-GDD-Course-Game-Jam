extends Node2D
class_name TheLamp

enum Direction {LEFT, RIGHT}

@export var light_source_max_energy: float = 250
var light_source_energy_debt: float = light_source_max_energy
var light_source_energy: float = light_source_max_energy

@export var friction: int = 1000
@export var energy_depletion_rate: int = 10
@export var lamp_light_minimum_energy: float = 0.9
@export var lamp_light_minimum_texture_scale: float = 0.7
@export var taken_energy_multiplier: int = 10
@export var no_light_damage: int = 100

# relative to player
@onready var initial_global_position: Vector2 = global_position
@onready var initial_position: Vector2 = position
@onready var target_position: Vector2 = position
@onready var last_global_position: Vector2 = global_position
@onready var lamp_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var lamp_point_light: PointLight2D = $AnimatedSprite2D/LightMix

@onready var character_node: PlatformerController2D = get_character_node()
@onready var on_change_delta_x: float = (initial_global_position.x - character_node.global_position.x)

func get_character_node() -> PlatformerController2D:
	var node: Node = self
	while not node is PlatformerController2D and node != null:
		node = node.get_parent()
	return node

func on_character_flip(direction: Direction) -> void:
	if direction == Direction.LEFT:
		target_position.x = -2 * on_change_delta_x + initial_position.x
	else:
		target_position.x = initial_position.x

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	character_node.connect("change_direction", on_character_flip)
	pass

func process_rotation(_delta: float) -> void:
	var delta_x = global_position.x - last_global_position.x
	rotation = clamp(delta_x / 30, -0.5, 0.5)
	last_global_position = global_position

func process_move(delta: float) -> void:
	var velocity = Vector2()
	velocity.x = (target_position.x - position.x) / (1 + (delta * friction))
	position.x += velocity.x

func get_light_energy_ratio() -> float:
	return light_source_energy / light_source_max_energy

func process_energy(delta: float) -> void:
	var energy_depletion = min(light_source_energy, energy_depletion_rate * delta)
	light_source_energy_debt -= energy_depletion
	light_source_energy -= energy_depletion
	if light_source_energy == 0:
		character_node.take_damage(no_light_damage, Vector2(0, 0))
	
	lamp_point_light.texture_scale = lamp_light_minimum_texture_scale + (1 - lamp_light_minimum_texture_scale) * get_light_energy_ratio()
	lamp_point_light.energy = lamp_light_minimum_energy + (1 - lamp_light_minimum_energy) * get_light_energy_ratio()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	process_rotation(delta)
	process_move(delta)
	process_energy(delta)

func add_energy(stored_energy: int) -> void:
	light_source_energy += stored_energy

var can_absord = false

func absorb_light(light_source: LightSource, damage: float) -> void:
	if light_source_energy_debt < light_source_max_energy * 0.8:
		can_absord = true
	if can_absord:
		var stored_energy = light_source.take_damage(damage) * taken_energy_multiplier
		light_source_energy_debt += stored_energy

		var light_particle = preload("res://scenes/TheLampLightParticle.tscn").instantiate()
		light_particle.connect("particle_arrived", add_energy)
		light_particle.global_position = light_source.global_position - global_position
		light_particle.stored_energy = stored_energy
		add_child(light_particle)
		if light_source_energy_debt >= light_source_max_energy:
			can_absord = false

func _get_configuration_warnings() -> PackedStringArray:
	var warnings:PackedStringArray = []
	if get_character_node() == null:
		warnings.append("Lamp should be a child of Player")

	warnings.append("StateChart's child must be a State")
	update_configuration_warnings() 
	return warnings
