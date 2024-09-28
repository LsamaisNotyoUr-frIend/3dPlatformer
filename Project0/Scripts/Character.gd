extends CharacterBody3D

const  gravity = 40.0

enum {IDLE, WALK, JUMP, DASH, RUN, REVERSEDASH, FALL, LANDING}
var current_anim = IDLE
@export var blend_speed = 15
var dash_duration = 0.3
var dash_timer = 0.0  
var dash_cooldown = 0.0
var dash_speed_multiplier = 0.6
var speed = 80.0
var slower_speed = 75.0
var jumpStrength = 12.0
var snapVector = Vector3.DOWN
var run_value:float = 0
var dash_value:float = 0
var fall_value:float = 0
var landing_value:float = 0
var reverse_dash_value:float = 0
var walkjump_value:float = 0
var current_speed
var finished_run = false

@onready var animation_player = $Mixamo/AnimationPlayer
@onready var mixamo = $Mixamo
@onready var spring_arm_3d = $SpringArm3D
@onready var camera = $SpringArm3D/Camera3D
@onready var animation_tree = $Mixamo/AnimationTree
@onready var timer = $"../Area3D/Timer"
@onready var character_placholder = $"."



func _ready(): 
	Engine.time_scale = 1.0

func _physics_process(delta):
	handle_animation(delta)
	var move_direction = Vector3.ZERO
	current_speed = velocity.z
	
	move_direction.z = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	
	if !is_on_floor() and dash_timer <= 0.1:
		velocity.y -= gravity * delta *1.1
		current_anim = LANDING
		
	if dash_cooldown >= 0.05:
		dash_cooldown -= delta
		
	if is_no_action_being_pressed():
		current_anim = IDLE
	
	var justLanded = is_on_floor() and snapVector == Vector3.ZERO
	var isJumping = is_on_floor() and Input.is_action_pressed("Jump")
	var isflying = !is_on_floor() and Input.is_action_just_pressed("Dash") and dash_cooldown <= 0.1
	var isRunning = is_on_floor() and Input.is_action_pressed("Dash")
	var isWalking = is_on_floor() and Input.is_action_pressed("Right") or Input.is_action_pressed("Left")
	var notRunning = is_on_floor() and Input.is_action_just_released("Dash")
	
	if move_direction.length() > 0.2:
		var look_direction = Vector2(velocity.z, velocity.x)
		mixamo.rotation.y = lerp_angle(mixamo.rotation.y, look_direction.angle(), 0.35)
			
	if isWalking and move_direction.length() > 0.1:
		current_speed=move_direction.z * speed * delta
		velocity.z = current_speed
		current_anim = WALK
	elif !isWalking:
		velocity.z = move_toward(velocity.z, 0, delta *3)
		
	
	if isJumping:
		velocity.y = jumpStrength
		
		snapVector = Vector3.ZERO
		current_anim= JUMP
	elif justLanded:
		snapVector = Vector3.DOWN
		current_anim= LANDING
		
	
	if isRunning and abs(move_direction.z) > 0.2:
		current_speed = move_direction.z * speed * 5 * delta
		velocity.z = current_speed
		current_anim = RUN
	elif !isRunning:
		velocity.z = move_toward(velocity.z, 0, delta* 6)
		
	if isflying and dash_timer <= 0.1:
		current_anim = DASH
		dash_timer = dash_duration
		var dash_speed = move_direction.z * speed * dash_speed_multiplier * delta
		velocity.z = move_toward(velocity.z, dash_speed, delta)
		print(velocity.z)
	
	if dash_timer > 0.1:
		dash_timer -= delta
		var dash_speed = move_direction.z * speed * dash_speed_multiplier * delta
		velocity.z += dash_speed
		dash_cooldown = 1.0
		
		
	move_and_slide()
	

	
func mightNeed(move_direction):
	move_direction.x = Input.get_action_strength("lookUp") - Input.get_action_strength("LookDown")
	velocity.x= move_direction.x * speed
	
func handle_animation(delta):
	update_tree()
	match current_anim:
		IDLE:
			run_value = lerp(run_value, float(0), blend_speed* delta)
			dash_value = lerp(dash_value, float(0), blend_speed* delta)
			walkjump_value = lerp(walkjump_value, float(0), blend_speed* delta)
			reverse_dash_value = lerp(reverse_dash_value, float(0), blend_speed* delta)
			fall_value = lerp(fall_value, float(0), blend_speed* delta)
			landing_value = lerp(landing_value, float(0), blend_speed* delta)
		RUN:
			run_value = lerp(run_value, 1.0, blend_speed* delta)
			dash_value = lerp(dash_value, float(0), blend_speed* delta)
			walkjump_value = lerp(walkjump_value, float(0), blend_speed* delta)
			reverse_dash_value = lerp(reverse_dash_value, float(0), blend_speed* delta)
			fall_value = lerp(fall_value, float(0), blend_speed* delta)
			landing_value = lerp(landing_value, float(0), blend_speed* delta)
		WALK:
			run_value = lerp(run_value, float(0), blend_speed* delta)
			dash_value = lerp(dash_value, float(0), blend_speed* delta)
			walkjump_value = lerp(walkjump_value, 1.0, blend_speed* delta)
			reverse_dash_value = lerp(reverse_dash_value, float(0), blend_speed* delta)
			fall_value = lerp(fall_value, float(0), blend_speed* delta)
			landing_value = lerp(landing_value, float(0), blend_speed* delta)
		JUMP:
			run_value = lerp(run_value, float(0), blend_speed* delta)
			dash_value = lerp(dash_value, float(0), blend_speed* delta)
			walkjump_value = lerp(walkjump_value, -1.0, blend_speed* delta)
			reverse_dash_value = lerp(reverse_dash_value, float(0), blend_speed* delta)
			fall_value = lerp(fall_value, float(0), blend_speed* delta)
			landing_value = lerp(landing_value, float(0), blend_speed* delta)
		DASH:
			run_value = lerp(run_value, float(0), blend_speed* delta)
			dash_value = lerp(dash_value, 1.0, 1.0)
			walkjump_value = lerp(walkjump_value, float(0), blend_speed* delta)
			reverse_dash_value = lerp(reverse_dash_value, float(0), blend_speed* delta)
			fall_value = lerp(fall_value, float(0), blend_speed* delta)
			landing_value = lerp(landing_value, float(0), blend_speed* delta)
		REVERSEDASH:
			run_value = lerp(run_value, float(0), blend_speed* delta)
			dash_value = lerp(dash_value, float(0), blend_speed* delta)
			walkjump_value = lerp(walkjump_value, float(0), blend_speed* delta)
			reverse_dash_value = lerp(reverse_dash_value, 1.0, blend_speed* delta)
			fall_value = lerp(fall_value, float(0), blend_speed* delta)
			landing_value = lerp(landing_value, float(0), blend_speed* delta)
		FALL:
			run_value = lerp(run_value, float(0), blend_speed* delta)
			dash_value = lerp(dash_value, float(0), blend_speed* delta)
			walkjump_value = lerp(walkjump_value, float(0), blend_speed* delta)
			reverse_dash_value = lerp(reverse_dash_value, float(0), blend_speed* delta)
			fall_value = lerp(fall_value, 1.0, blend_speed* delta)
			landing_value = lerp(landing_value, float(0), blend_speed* delta)
		LANDING:
			run_value = lerp(run_value, float(0), blend_speed* delta)
			dash_value = lerp(dash_value, float(0), blend_speed* delta)
			walkjump_value = lerp(walkjump_value, float(0), blend_speed* delta)
			reverse_dash_value = lerp(reverse_dash_value, float(0), blend_speed* delta)
			fall_value = lerp(fall_value, float(0), blend_speed* delta)
			landing_value = lerp(landing_value, 1.0, blend_speed* delta)
			
	
func update_tree():
	animation_tree["parameters/run/blend_amount"] = run_value
	animation_tree["parameters/dash/blend_amount"] = dash_value
	animation_tree["parameters/walkjump/blend_amount"] = walkjump_value
	animation_tree["parameters/reversedash/blend_amount"] = reverse_dash_value
	animation_tree["parameters/fall/blend_amount"] = fall_value
	animation_tree["parameters/landing/blend_amount"] = landing_value


func _on_area_3d_body_entered(_body):
	Engine.time_scale = 0.5
	timer.start()

func _on_timer_timeout():
	character_placholder.queue_free()
	get_tree().reload_current_scene()
	
func is_no_action_being_pressed() -> bool:
	var actions = InputMap.get_actions()  
	for action in actions:
		if Input.is_action_pressed(action):
			return false
	return true  # No actions are pressed
