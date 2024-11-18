extends CharacterBody2D

class_name Player

@onready var animated_sprite_2d = $AnimatedSprite2D as AnimatedSprite2D
@onready var area_collision_shape_2d = $Area2D/AreaCollisionShape2D
@onready var body_collidion_shape_2d = $BodyCollisionShape2D
@onready var area_2d = $Area2D

@export var climb_velocity = 100
@export var climb_time = 1.0
var escalando: bool = false
var tempo_segurando: float = 0.0
var toca_parede_esquerda: bool = false
var toca_parede_direita: bool = false

@onready var left_raycast = $LeftRayCast2D
@onready var right_raycast = $RightRayCast2D2

@export_group("Locomotion")
@export var speed = 150.0
@export var jump_velocity = -410
@export_group("")

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor() and not escalando:
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("up") and is_on_floor():
		velocity.y = jump_velocity
	
	if Input.is_action_just_released("up") and velocity.y < 0:
		velocity.y *= 0.7
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed * delta * 2.5)
	
	toca_parede_esquerda = left_raycast.is_colliding()
	toca_parede_direita = right_raycast.is_colliding()
	
	if toca_parede_esquerda or toca_parede_direita:
		if Input.is_action_pressed("space"):
			escalar_parede(delta)
		else:
			tempo_segurando += delta
			if tempo_segurando >= climb_time:
				escalando = false
	else:
		tempo_segurando = 0.0
		escalando = false 
	
	animated_sprite_2d.trigger_animation(velocity, direction)
	
	move_and_slide()

func escalar_parede(delta):
	if escalando:
		velocity.y = -climb_velocity
		#animation.play("andar")
		return
	
	tempo_segurando = 0.0
	escalando = true
	velocity.y = -climb_velocity
	#animation.play("andar")
