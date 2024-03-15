extends Sprite2D
class_name TheLampParticle

@export var stored_energy: float = 0

@onready var the_lamp: TheLamp
@onready var destination_offset: Vector2 = Vector2(0, 10)
@onready var initial_global_position: Vector2 = global_position
@onready var path: Path2D = Path2D.new()

var rng = RandomNumberGenerator.new()
var rotation_angle: float

signal particle_arrived(stored_energy: int)

#func _init(global_position: Vector2, stored_energy: int):
#	self.global_position = global_position
#	self.stored_energy = stored_energy
#	pass

func get_the_lamp_parent():
	var node = self
	while not node is TheLamp && node != null:
		node = node.get_parent()
	return node

func random_direction():
	# find midpoint of two lines and rotate the point based on start point by random degree
	# degree kept big s.t. the bezier curve doesn't looks like a straight line
	var mid_point: Vector2 = (initial_global_position + the_lamp.global_position + destination_offset) / 2 - initial_global_position; 
	if rng.randi_range(0, 1) == 0:
		mid_point = mid_point.rotated(rotation_angle)
	else:
		mid_point = mid_point.rotated(rotation_angle)
	return mid_point

func initiate_random_variables():
	scale = Vector2(1, 1) * rng.randf_range(0.7, 1)
	if rng.randi_range(0, 1) == 0:
		rotation_angle = rng.randf_range(-PI/2, -PI/4)
	else:
		rotation_angle = rng.randf_range(PI/4, PI/2)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initiate_random_variables()

func get_distance_to_destination() -> float:
	var distance_vector = abs(the_lamp.global_position + destination_offset - global_position)
	return distance_vector.x + distance_vector.y

var t = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	if not get_the_lamp_parent():
		return
	if not the_lamp:
		the_lamp = get_the_lamp_parent()
	
	path.curve = Curve2D.new()
	path.curve.add_point(initial_global_position)
	path.curve.add_point(the_lamp.global_position + destination_offset, random_direction(), Vector2())
	
	t += delta
	var path_length = 5*t*t*t
	global_position = path.curve.sample_baked(path_length * path.curve.get_baked_length(), true)
	
	if get_distance_to_destination() <= 1:
		particle_arrived.emit(self.stored_energy)
		queue_free()
