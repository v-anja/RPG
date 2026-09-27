extends CharacterBody2D

enum State{
	IDLE,
	RUN, 
	ATTACK, 
	DEAD
}

var direction: Vector2 = Vector2(1, 0)
var speed: int = 400
var state: State = State.IDLE
var attack_damage: int = 60
var facing_left: bool = false
var attack_can_damage: bool = false

@onready var animation_tree : AnimationTree = $AnimationTree
@onready var animation_playback : AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]

func _ready() -> void: 

	animation_tree.active = true

	$HitBoxLeft.monitoring = false
	$HitBoxRight.monitoring = false


func _physics_process(_delta: float) -> void:

	direction = Input.get_vector("left", "right", "up", "down")

	if Input.is_action_just_pressed("attack"):
		
		
		state = State.ATTACK
		velocity = Vector2.ZERO

		
		animation_playback.start("attack_right", true)

	elif state != State.ATTACK:
		velocity = direction * speed

		if direction != Vector2.ZERO:
			state = State.RUN
		else:
			state = State.IDLE

		if abs(direction.x) > abs(direction.y):
			if direction.x < 0:
				facing_left = true
			elif direction.x > 0:
				facing_left = false

			$Sprite2D.flip_h = facing_left
			#$HitBox.scale.x = -1 if facing_left else 1
	update_animation()
	move_and_slide()
	

func update_animation() -> void:
	match state: 
		State.IDLE: 
			animation_playback.travel("idle")
		State.RUN: 
			animation_playback.travel("run")
		State.ATTACK: 
			pass
		State.DEAD: 
			animation_playback.travel("dead")
	

func attack_finished() -> void:
	#$HitBoxLeft.monitoring = false
	#$HitBoxRight.monitoring = false
	disable_attack_hitbox()

	state = State.IDLE
	animation_playback.start("idle", true)


#THISSS ONEEE 
func _on_hit_box_area_entered(area: Area2D) -> void:
	#maybe check for if the method take damage exists first but wtv
	print("entered hitbox")
	if not attack_can_damage:
		return

	if area.owner.has_method("take_damage"):
		print("ACTUAL ATTACK HIT")
		area.owner.take_damage(attack_damage)



func enable_attack_hitbox() -> void:
	
	attack_can_damage = true
	if facing_left:
		$HitBoxLeft.monitoring = true
		$HitBoxRight.monitoring = false
	else:
		$HitBoxRight.monitoring = true
		$HitBoxLeft.monitoring = false


func disable_attack_hitbox() -> void:
	attack_can_damage = false
	$HitBoxLeft.monitoring = false
	$HitBoxRight.monitoring = false
	
