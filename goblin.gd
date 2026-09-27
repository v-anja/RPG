extends CharacterBody2D

enum State{
	IDLE,
	CHASE, 
	RETURN, 
	ATTACK, 
	DEAD
	
}

var hitpoints:int = 180
@export var death_packed: PackedScene
@onready var sprite: AnimatedSprite2D = $Sprite2D

@export var speed:int = 250
@export var attack_speed: float = 1.0 
@export var attack_range:float = 80.0
@export var aggro_range:float = 256.0 

var state:State = State.IDLE

@onready var spawn_point:Vector2 = global_position

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")



func _ready() -> void:

	sprite.play("idle")

	
func _physics_process(delta: float) -> void:
	if state == State.DEAD: 
		return 
	if state == State.ATTACK: 
		return 
		
	if distance_to_player() <= attack_range: 
		state = State.ATTACK
		attack()
	elif distance_to_player() <= aggro_range: 
		state = State.CHASE
		move()
	elif global_position.distance_to(spawn_point) > 32: 
		state = State.RETURN
		move()
	elif state != State.IDLE: 
		state = State.IDLE
		update_animation()
	

func distance_to_player() ->float: 
	return global_position.distance_to(player.global_position)

func move()-> void: 
	var move_direction: Vector2

	if state == State.CHASE:
		move_direction = global_position.direction_to(player.global_position)

	elif state == State.RETURN:
		move_direction = global_position.direction_to(spawn_point)

	else:
		velocity = Vector2.ZERO
		return

	velocity = move_direction * speed

	
	if move_direction.x < 0:
		sprite.flip_h = true
	elif move_direction.x > 0:
		sprite.flip_h = false

	update_animation()
	move_and_slide() 

func attack()-> void: 
	velocity = Vector2.ZERO

	var attack_dir := global_position.direction_to(player.global_position)

	sprite.flip_h = attack_dir.x < 0
	sprite.play("attack")
	
	
	
func update_animation()-> void: 
	match state:
		State.IDLE:
			if sprite.animation != "idle":
				sprite.play("idle")

		State.CHASE, State.RETURN:
			if sprite.animation != "right":
				sprite.play("right")


func take_damage(damage_taken: int) -> void: 
	hitpoints -= damage_taken
	if hitpoints<= 0: 
		death()
		

func death() -> void: 
	var death_scene: Node2D = death_packed.instantiate()
	death_scene.position = global_position + Vector2(0.0, -32.0)
	%Effects.add_child(death_scene)
	queue_free()
