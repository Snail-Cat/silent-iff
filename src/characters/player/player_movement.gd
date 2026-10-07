extends GameCharacter
class_name Player

@export var run_speed: int = 100

var is_running: bool
const PUSH_FORCE: int = 300

func _ready() -> void:
	super()
	# Define a posição que o player ira iniciar o level
	var playerPosition: Vector2 = LevelManager.get_player_spawn_position()
	if playerPosition:
		position = LevelManager.get_player_spawn_position()
	
	# Define estados padrões para as animações
	facing_direction = Direction.DOWN
	movement_state = Movement.IDLE
	is_running = false
	
	# Envia o player_controller para o Leve Manager
	if LevelManager:
		LevelManager.set_player_controller($Controller)


func _process(delta: float) -> void:
	player_interaction_area()


func _physics_process(_delta: float) -> void:
	push_block()


# Movimentação do player
func move(direction: Vector2) -> void:
	# Atualiza as variáveis de estado do player
	set_facing_direction_vector(direction)
	set_player_movement(direction)
	
	# Movimenta o player
	velocity = direction * (run_speed if (movement_state == Movement.RUN) else walk_speed)
	move_and_slide()


# Atualiza o estado com o tipo de movimento que o sprite irá mostrar
func set_player_movement(direction: Vector2) -> void:
	if (direction.length() == 0):
		movement_state = Movement.IDLE
	else:
		if (is_running):
			movement_state = Movement.RUN
		else:
			movement_state = Movement.WALK


# Player andando ou correndo
func set_player_run(run_state: bool) -> void:
	is_running = run_state


# Interação com o objetos que podem ser empurrados
func push_block() -> void:
	var colliding: KinematicCollision2D = get_last_slide_collision()
	if colliding:
		var collinding_node = colliding.get_collider()
		if !collinding_node:
			return
			
		if collinding_node.is_in_group("pushable") and movement_state != Movement.IDLE:
			var collision_normal: Vector2 = colliding.get_normal()
			var force_vector: Vector2
			if abs(collision_normal.x) > abs(collision_normal.y):
				force_vector = Vector2(1, 0) * sign(collision_normal.x) * (-1)
			else:
				force_vector = Vector2(0, 1) * sign(collision_normal.y) * (-1)
				
			collinding_node.apply_central_force(force_vector * PUSH_FORCE)


# Atualiza a posição do collider de interação do player com os ambiente
# Muda de acordo com a posição do jogador pra sempre estar na direção do movimento
func player_interaction_area() -> void:
	if (facing_direction == Direction.RIGHT):
		$InteractionArea.position = Vector2(20, 5)
	elif (facing_direction == Direction.LEFT):
		$InteractionArea.position = Vector2(-20, 5)
	elif (facing_direction == Direction.DOWN):
		$InteractionArea.position = Vector2(0, 20)
	elif (facing_direction == Direction.UP):
		$InteractionArea.position = Vector2(0, -10)
