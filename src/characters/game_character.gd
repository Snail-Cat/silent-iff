extends CharacterBody2D
class_name GameCharacter
## Classe base para o jogador e NPCs, com animações básicas

enum Direction {
	RIGHT,
	LEFT,
	DOWN,
	UP
}

enum Movement {
	IDLE,
	WALK,
	RUN
}

const GROUP_KEY := 'game_character'

@export var walk_speed: int = 150
var facing_direction: Direction
var movement_state: Movement
var animated_sprite: AnimatedSprite2D


func _init():
	add_to_group(GROUP_KEY)


func _ready():
	animated_sprite = get_node_or_null("AnimatedSprite2D")
	print(get_node_or_null("AnimatedSprite2D"))


func set_facing_direction_vector(direction: Vector2) -> void:
	if (direction.x > 0):
		facing_direction = Direction.RIGHT
	elif (direction.x < 0):
		facing_direction = Direction.LEFT
	elif (direction.y > 0):
		facing_direction = Direction.DOWN
	elif (direction.y < 0):
		facing_direction = Direction.UP
	
	update_player_animation()


func set_facing_direction(direction: Direction) -> void:
	facing_direction = direction
	update_player_animation()


func set_movement_state(movement: Movement):
	movement_state = movement
	update_player_animation()


func update_player_animation() -> void:
	if !animated_sprite:
		return
	
	if (facing_direction == Direction.RIGHT):
		if (movement_state == Movement.IDLE):
			animated_sprite.play("idle_right")
		if (movement_state == Movement.WALK):
			animated_sprite.play("walk_right")
	
	if (facing_direction == Direction.LEFT):
		if (movement_state == Movement.IDLE):
			animated_sprite.play("idle_left")
		if (movement_state == Movement.WALK):
			animated_sprite.play("walk_left")
	
	if (facing_direction == Direction.DOWN):
		if (movement_state == Movement.IDLE):
			animated_sprite.play("idle_front")
		if (movement_state == Movement.WALK):
			animated_sprite.play("walk_front")
	
	if (facing_direction == Direction.UP):
		if (movement_state == Movement.IDLE):
			animated_sprite.play("idle_back")
		if (movement_state == Movement.WALK):
			animated_sprite.play("walk_back")
