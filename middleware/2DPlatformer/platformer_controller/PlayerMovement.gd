extends PlatformerController2D
class_name PlayerMovement

static var player_movement_node: PlayerMovement = self

@export var can_move_while_attack : bool = false
@export var air_hovering_timer : float = 50
@export var air_hovering_attack1_modifier : float = 200
@export var air_hovering_attack2_modifier : float = 70
@export var roll_speed : int = 10000
@export var roll_speed_divider : int = 4
@export var roll_median_frame : int = 4

enum Direction {LEFT, RIGHT}
var current_direction = Direction.RIGHT

func _ready():	
	player_movement_node = self
	if is_coyote_time_enabled:
		add_child(coyote_timer)
		coyote_timer.wait_time = coyote_time
		coyote_timer.one_shot = true
	
	if is_jump_buffer_enabled:
		add_child(jump_buffer_timer)
		jump_buffer_timer.wait_time = jump_buffer
		jump_buffer_timer.one_shot = true


func process_input(_event):
	acc.x = 0
	if Input.is_action_pressed(input_left):
		acc.x = -max_acceleration
	
	if Input.is_action_pressed(input_right):
		acc.x = max_acceleration
	
	if Input.is_action_just_pressed(input_jump):
		holding_jump = true
		start_jump_buffer_timer()
		if (not can_hold_jump and can_ground_jump()) or can_double_jump():
			jump()
		
	if Input.is_action_just_released(input_jump):
		holding_jump = false

func apply_friction(delta):
	# Apply friction
	velocity.x *= 1 / (1 + (delta * friction))

func process_physics(delta):
	if is_coyote_timer_running() or current_jump_type == JumpType.NONE:
		jumps_left = max_jump_amount
	if is_feet_on_ground() and current_jump_type == JumpType.NONE:
		start_coyote_timer()
		
	# Check if we just hit the ground this frame
	if not _was_on_ground and is_feet_on_ground():
		current_jump_type = JumpType.NONE
		if is_jump_buffer_timer_running() and not can_hold_jump: 
			jump()
		
		hit_ground.emit()
	
	
	# Cannot do this in _input because it needs to be checked every frame
	if Input.is_action_pressed(input_jump):
		if can_ground_jump() and can_hold_jump:
			jump()
	
	var gravity = apply_gravity_multipliers_to(default_gravity)
	acc.y = gravity
	
	apply_friction(delta)
	velocity += acc * delta
	
	
	_was_on_ground = is_feet_on_ground()
	move_and_slide()

@onready var player_state_chart : StateChart = $"../StateChart"
@onready var player_animation_player : AnimationPlayer = $PlayerAnimationPlayer
@onready var effect_animation_player : EffectAnimationPlayer = $EffectAnimationPlayer
@onready var animated_sprite: AnimatedSprite2D = $McAnimatedSprites
@onready var player_hurt_box: HurtBox = $McAnimatedSprites/HurtBox

func _on_player_animation_player_animation_finished(_anim_name) -> void:
	player_state_chart.send_event("AnimationFinished")

func _on_idle_state_entered() -> void:
	_on_idle_state_input(null)
	player_animation_player.play("Player/idle")

func _on_idle_state_input(event: InputEvent) -> void:
	if Input.is_action_pressed(input_left) or Input.is_action_pressed(input_right):
		player_state_chart.send_event("PlayerRun")
	if Input.is_action_just_pressed("attack"):
		player_state_chart.send_event("PlayerAttack")
	if Input.is_action_just_pressed("jump"):
		player_state_chart.send_event("PlayerJump")
	if Input.is_action_just_pressed("roll"):
		player_state_chart.send_event("PlayerRoll")
	process_input(event)

func _on_idle_state_physics_processing(delta: float) -> void:
	process_physics(delta)

var _is_2nd_attack_buffered = false

func _on_ground_attack_state_entered():
	$"../AudioStreamPlayer2D".play()
	player_animation_player.play("Player/attack")

func _on_ground_attack_state_input(_event: InputEvent) -> void:
	if Input.is_action_pressed("attack"):
		_is_2nd_attack_buffered = true

func _on_ground_attack_state_physics_processing(delta: float) -> void:
	if !can_move_while_attack:
		acc.x = 0
		velocity.x = 0
	process_physics(delta)

func _on_ground_attack_event_received(event: StringName) -> void:
	if event == "AnimationFinished":
		if _is_2nd_attack_buffered:
			_is_2nd_attack_buffered = false
			player_state_chart.send_event("PlayerAttack2")
		else:
			player_state_chart.send_event("PlayerIdle")
	
func _on_ground_attack_2_state_entered():
	$"../AudioStreamPlayer2D".play()
	player_animation_player.play("Player/attack2")

func _on_ground_attack_2_state_physics_processing(delta: float) -> void:
	if !can_move_while_attack:
		acc.x = 0
		velocity.x = 0
	process_physics(delta)

func _on_ground_attack_2_event_received(_event: StringName) -> void:
	player_state_chart.send_event("PlayerIdle")



func _on_run_state_entered() -> void:
	player_animation_player.play("Player/run")

func _on_run_state_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("attack"):
		player_state_chart.send_event("PlayerAttack")
	if Input.is_action_just_pressed("jump"):
		player_state_chart.send_event("PlayerJump")
	if Input.is_action_just_pressed("roll"):
		player_state_chart.send_event("PlayerRoll")
	process_input(event)

func _on_run_state_physics_processing(delta: float) -> void:
	process_physics(delta)
	if !is_feet_on_ground():
		player_state_chart.send_event("PlayerJump")		
	if abs(velocity.x) < 50 and !is_on_wall():
		player_state_chart.send_event("PlayerIdle")


func _on_jump_state_entered() -> void:
	player_animation_player.play("Player/jump")

func _on_jump_state_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("attack"):
		player_state_chart.send_event("PlayerAirAttack")
	process_input(event)

func _on_jump_state_physics_processing(delta: float) -> void:
	process_physics(delta)
	if is_feet_on_ground():
		player_state_chart.send_event("PlayerIdle")


func _on_air_attack_state_entered() -> void:
	$"../AudioStreamPlayer2D".play()
	player_animation_player.play("Player/attack")

func _on_air_attack_state_input(event: InputEvent) -> void:
	if Input.is_action_pressed("attack"):
		_is_2nd_attack_buffered = true
	process_input(event)

var _is_air_attack_hit: float = 0

func toggle_air_attack_hit(state: bool):
	_is_air_attack_hit = air_hovering_timer

func _on_air_attack_state_physics_processing(delta: float) -> void:
	if _is_air_attack_hit <= 0:
		process_physics(delta)
	else:
		_is_air_attack_hit -= air_hovering_attack1_modifier * delta

func _on_air_attack_event_received(event: StringName) -> void:
	if event == "AnimationFinished":
		if _is_2nd_attack_buffered:
			_is_2nd_attack_buffered = false
			player_state_chart.send_event("PlayerAirAttack2")
		elif is_feet_on_ground():
			player_state_chart.send_event("PlayerIdle")
		else:
			player_state_chart.send_event("PlayerJump")

func _on_air_attack_2_state_entered() -> void:
	$"../AudioStreamPlayer2D".play()
	player_animation_player.play("Player/attack2")

func _on_air_attack_2_state_input(event: InputEvent) -> void:
	process_input(event)

func _on_air_attack_2_state_physics_processing(delta: float) -> void:
	if _is_air_attack_hit <= 0:
		process_physics(delta)
	else:
		_is_air_attack_hit -= air_hovering_attack2_modifier * delta
	if is_feet_on_ground():
		player_state_chart.send_event("PlayerAttack2")
		

func _on_air_attack_2_event_received(event: StringName) -> void:
	if event == "AnimationFinished":
		if is_feet_on_ground():
			player_state_chart.send_event("PlayerIdle")
		else:
			player_state_chart.send_event("PlayerJump")


func _on_roll_state_entered() -> void:
	player_animation_player.play("Player/roll")
	# TODO: set able to take dmg false

func _on_roll_state_physics_processing(delta: float) -> void:
	var cur_speed: float = roll_speed_divider * roll_speed / (roll_speed_divider + abs(animated_sprite.frame - roll_median_frame))
	if current_direction == Direction.LEFT:
		acc.x = -cur_speed
	else:
		acc.x = cur_speed
	process_physics(delta)

func _on_roll_event_received(event: StringName) -> void:
	if event == "AnimationFinished":
		if is_feet_on_ground():
			player_state_chart.send_event("PlayerIdle")
		else:
			player_state_chart.send_event("PlayerJump")

signal change_direction(direction: Direction)

func _on_face_left_state_entered() -> void:
	current_direction = Direction.LEFT
	change_direction.emit(current_direction)
	animated_sprite.scale.x = -1

func _on_face_left_state_input(event: InputEvent) -> void:
	if Input.is_action_pressed(input_right):
		player_state_chart.send_event("PlayerRight")

func _on_face_right_state_entered() -> void:
	current_direction = Direction.RIGHT
	change_direction.emit(current_direction)
	animated_sprite.scale.x = 1

func _on_face_right_state_input(event: InputEvent) -> void:
	if Input.is_action_pressed(input_left) && !Input.is_action_pressed(input_right):
		player_state_chart.send_event("PlayerLeft")

var hurt_velocity: Vector2 
var initial_velocity: Vector2 

func _on_hurt_state_entered() -> void:
	player_animation_player.play("Player/hurt")
	effect_animation_player.play_effect(2, "invulnerable")
	initial_velocity = velocity
	velocity = hurt_velocity

func _on_hurt_state_physics_processing(delta: float) -> void:
	apply_friction(delta)
	move_and_slide()

func _on_hurt_event_received(event: StringName) -> void:
	if event == "AnimationFinished":
		if is_feet_on_ground():
			player_state_chart.send_event("PlayerIdle")
		else:
			player_state_chart.send_event("PlayerJump")

func _on_hurt_state_exited() -> void:
	acc.x = 0
	hurt_velocity = Vector2()
	velocity = Vector2()

func _on_death_state_entered() -> void:
	player_animation_player.play("Player/death")
	effect_animation_player.play("death")

func _on_death_state_physics_processing(delta: float) -> void:
	apply_friction(delta)

func _on_effect_animation_player_on_effect_stop(effect: StringName) -> void:
	if effect == "invulnerable":
		# reset hurtbox state
		player_hurt_box.monitorable = false
		player_hurt_box.monitorable = true

signal player_low_health
signal player_died

func _on_on_hit(damage: int, direction_vector: Vector2) -> void:
	if direction_vector.x < 0: 
		hurt_velocity.x = on_hurt_knockback # go to left
		player_state_chart.send_event("PlayerLeft")
	if direction_vector.x > 0: 
		hurt_velocity.x = -on_hurt_knockback # go to right
		player_state_chart.send_event("PlayerRight")
	player_state_chart.send_event("PlayerHurt")
	# empower when low
	if current_hitpoint * 3 < max_hit_point:
		player_low_health.emit()
		max_acceleration = 10000
		max_jump_height = DEFAULT_MAX_JUMP_HEIGHT
		player_animation_player.speed_scale = 3

func _on_hit_point_depleted() -> void:
	player_died.emit()
	player_state_chart.send_event("PlayerDeath")

