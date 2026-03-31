class_name Enemy
extends CharacterBody2D

signal died(pos: Vector2, exp_value: int)

## One entry per anime universe — two enemy types each.
enum EnemyType {
	# Jujutsu Kaisen
	CURSE,           # fast, fragile melee
	SPECIAL_GRADE,   # tough, charges at player
	# One Piece
	MARINE,          # steady, armoured melee
	HENCHMAN,        # agile melee brawler
	# Dragon Ball
	FRIEZA_SOLDIER,  # ranged ki blasts
	SAIBAMAN,        # extreme-speed rush
	# Bleach
	HOLLOW,          # slow, tanky melee
	ARRANCAR,        # ranged cero blasts
	# My Hero Academia
	VILLAIN,         # standard melee
	NOMU,            # ultra-tank, massive damage
	# One Punch Man
	MONSTER,         # fast melee
	DRAGON_LEVEL,    # fast charge, very dangerous
}

enum AttackPattern { MELEE, RANGED, CHARGE, RUSH, TANK }

@export var enemy_type: EnemyType = EnemyType.CURSE
@export var is_boss := false

var base_speed := 80.0
var base_health := 30.0
var base_damage := 10.0
var base_exp := 20

var current_health: float
var speed: float
var damage: float
var exp_drop: int
var _attack_pattern: AttackPattern = AttackPattern.MELEE

var _player: Node2D = null
var _flash_timer := 0.0
var _damage_cooldown := 0.0
const DAMAGE_INTERVAL := 0.6

# State for charge/rush attack patterns
var _charge_timer := 3.0
var _charge_active := false
var _charge_duration := 0.0

func _ready() -> void:
	add_to_group("enemies")
	_apply_type_stats()
	current_health = base_health
	speed = base_speed
	damage = base_damage
	exp_drop = base_exp
	queue_redraw()

## Populate base stats from enemy_type (and apply boss multipliers when is_boss).
func _apply_type_stats() -> void:
	match enemy_type:
		EnemyType.CURSE:
			base_speed = 95.0; base_health = 20.0; base_damage = 10.0; base_exp = 15
			_attack_pattern = AttackPattern.MELEE
		EnemyType.SPECIAL_GRADE:
			base_speed = 70.0; base_health = 70.0; base_damage = 18.0; base_exp = 40
			_attack_pattern = AttackPattern.CHARGE
		EnemyType.MARINE:
			base_speed = 60.0; base_health = 40.0; base_damage = 8.0; base_exp = 20
			_attack_pattern = AttackPattern.MELEE
		EnemyType.HENCHMAN:
			base_speed = 80.0; base_health = 25.0; base_damage = 12.0; base_exp = 15
			_attack_pattern = AttackPattern.MELEE
		EnemyType.FRIEZA_SOLDIER:
			base_speed = 65.0; base_health = 35.0; base_damage = 8.0; base_exp = 20
			_attack_pattern = AttackPattern.RANGED
		EnemyType.SAIBAMAN:
			base_speed = 110.0; base_health = 15.0; base_damage = 10.0; base_exp = 15
			_attack_pattern = AttackPattern.RUSH
		EnemyType.HOLLOW:
			base_speed = 55.0; base_health = 50.0; base_damage = 14.0; base_exp = 25
			_attack_pattern = AttackPattern.MELEE
		EnemyType.ARRANCAR:
			base_speed = 85.0; base_health = 45.0; base_damage = 16.0; base_exp = 30
			_attack_pattern = AttackPattern.RANGED
		EnemyType.VILLAIN:
			base_speed = 75.0; base_health = 30.0; base_damage = 10.0; base_exp = 20
			_attack_pattern = AttackPattern.MELEE
		EnemyType.NOMU:
			base_speed = 45.0; base_health = 100.0; base_damage = 25.0; base_exp = 50
			_attack_pattern = AttackPattern.TANK
		EnemyType.MONSTER:
			base_speed = 90.0; base_health = 30.0; base_damage = 12.0; base_exp = 20
			_attack_pattern = AttackPattern.MELEE
		EnemyType.DRAGON_LEVEL:
			base_speed = 100.0; base_health = 80.0; base_damage = 22.0; base_exp = 45
			_attack_pattern = AttackPattern.CHARGE
	if is_boss:
		base_health  *= 3.0
		base_damage  *= 2.0
		base_speed   *= 1.5
		base_exp     *= 3

## Called by WaveManager after adding to the scene tree.
func setup(health_mult: float, speed_bonus: float) -> void:
	base_health = base_health * health_mult
	current_health = base_health
	speed = base_speed + speed_bonus
	damage = base_damage
	exp_drop = int(base_exp * health_mult)
	queue_redraw()

# ---------------------------------------------------------------------------
# Physics / movement
# ---------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node2D
		if _player == null:
			return
	match _attack_pattern:
		AttackPattern.MELEE:   _behavior_melee(delta)
		AttackPattern.RANGED:  _behavior_ranged(delta)
		AttackPattern.CHARGE:  _behavior_charge(delta)
		AttackPattern.RUSH:    _behavior_rush(delta)
		AttackPattern.TANK:    _behavior_tank(delta)

## Standard straight-line pursuit with contact damage.
func _behavior_melee(delta: float) -> void:
	var dir := (_player.global_position - global_position).normalized()
	velocity = dir * speed
	move_and_slide()
	_tick_contact_damage(delta, 28.0)

## Maintains standoff distance; fires a ranged damage pulse every 2 s.
func _behavior_ranged(delta: float) -> void:
	var dist := global_position.distance_to(_player.global_position)
	var dir  := (_player.global_position - global_position).normalized()
	if dist > 180.0:
		velocity = dir * speed
	elif dist < 120.0:
		velocity = -dir * (speed * 0.5)
	else:
		velocity = Vector2.ZERO
	move_and_slide()
	if _damage_cooldown > 0.0:
		_damage_cooldown -= delta
	elif dist < 300.0:
		if _player.has_method("take_damage"):
			_player.take_damage(damage)
		_damage_cooldown = 2.0

## Slow creep then a fast 0.8 s sprint every 3 s.
func _behavior_charge(delta: float) -> void:
	if _charge_active:
		_charge_duration -= delta
		var dir := (_player.global_position - global_position).normalized()
		velocity = dir * speed * 2.5
		if _charge_duration <= 0.0:
			_charge_active = false
			_charge_timer = 3.0
	else:
		_charge_timer -= delta
		var dir := (_player.global_position - global_position).normalized()
		velocity = dir * speed * 0.4
		if _charge_timer <= 0.0:
			_charge_active = true
			_charge_duration = 0.8
	move_and_slide()
	_tick_contact_damage(delta, 32.0)

## Fastest movement straight at player, slightly larger contact range.
func _behavior_rush(delta: float) -> void:
	var dir := (_player.global_position - global_position).normalized()
	velocity = dir * speed
	move_and_slide()
	_tick_contact_damage(delta, 30.0)

## Slow but unstoppable; largest contact range and highest base damage.
func _behavior_tank(delta: float) -> void:
	var dir := (_player.global_position - global_position).normalized()
	velocity = dir * speed
	move_and_slide()
	_tick_contact_damage(delta, 35.0)

func _tick_contact_damage(delta: float, contact_range: float) -> void:
	if _damage_cooldown > 0.0:
		_damage_cooldown -= delta
	elif global_position.distance_to(_player.global_position) < contact_range:
		if _player.has_method("take_damage"):
			_player.take_damage(damage)
		_damage_cooldown = DAMAGE_INTERVAL

# ---------------------------------------------------------------------------
# Visual flash on hit
# ---------------------------------------------------------------------------

func _process(delta: float) -> void:
	if _flash_timer > 0.0:
		_flash_timer -= delta
		modulate = Color(2.0, 0.5, 0.5) if int(_flash_timer * 20) % 2 == 0 else Color.WHITE
		if _flash_timer <= 0.0:
			modulate = Color.WHITE

func take_damage(amount: float) -> void:
	current_health -= amount
	_flash_timer = 0.15
	if current_health <= 0.0:
		_on_death()

func _on_death() -> void:
	died.emit(global_position, exp_drop)
	queue_free()

# ---------------------------------------------------------------------------
# Drawing — distinct palette / silhouette per type; 1.5× scale for bosses
# ---------------------------------------------------------------------------

func _draw() -> void:
	var s := 1.5 if is_boss else 1.0
	match enemy_type:
		EnemyType.CURSE:
			_draw_figure(s, Color(0.25, 0.08, 0.35), Color(0.6, 0.0, 0.8, 0.4), Color(0.9, 0.0, 0.0))
		EnemyType.SPECIAL_GRADE:
			_draw_figure(s, Color(0.15, 0.00, 0.25), Color(0.8, 0.0, 1.0, 0.5), Color(1.0, 0.6, 0.0))
			# Cursed-energy sigils orbiting the head
			for i in range(4):
				var a := i * PI / 2.0
				draw_circle(Vector2(cos(a) * 16.0 * s, sin(a) * 16.0 * s - 10.0 * s),
						3.0 * s, Color(0.8, 0.0, 1.0, 0.7))
		EnemyType.MARINE:
			_draw_figure(s, Color(0.10, 0.10, 0.50), Color(0.2, 0.2, 0.8, 0.3), Color(0.9, 0.9, 0.0))
			# Epaulettes
			draw_rect(Rect2(-13.0 * s, -7.0 * s, 6.0 * s, 4.0 * s), Color(0.8, 0.8, 1.0))
			draw_rect(Rect2(7.0 * s,  -7.0 * s, 6.0 * s, 4.0 * s), Color(0.8, 0.8, 1.0))
		EnemyType.HENCHMAN:
			_draw_figure(s, Color(0.40, 0.25, 0.10), Color(0.5, 0.3, 0.1, 0.3), Color(0.7, 0.2, 0.0))
		EnemyType.FRIEZA_SOLDIER:
			_draw_figure(s, Color(0.50, 0.30, 0.60), Color(0.6, 0.4, 0.8, 0.3), Color(0.0, 0.8, 1.0))
			# Armour chest-plate overlay
			draw_rect(Rect2(-9.0 * s, -3.0 * s, 18.0 * s, 10.0 * s), Color(0.9, 0.8, 1.0, 0.5))
		EnemyType.SAIBAMAN:
			# Small, round, plant-like creature
			draw_circle(Vector2.ZERO, 14.0 * s, Color(0.1, 0.5, 0.1, 0.4))
			draw_circle(Vector2(0.0, -2.0 * s), 12.0 * s, Color(0.2, 0.6, 0.1))
			draw_circle(Vector2(-4.0 * s, -4.0 * s), 3.0 * s, Color(1.0, 0.2, 0.0))
			draw_circle(Vector2(4.0 * s,  -4.0 * s), 3.0 * s, Color(1.0, 0.2, 0.0))
			for i in range(4):
				var a := i * PI / 2.0 + PI / 4.0
				draw_line(Vector2.ZERO,
						Vector2(cos(a) * 14.0 * s, sin(a) * 14.0 * s),
						Color(0.2, 0.5, 0.1), 2.0 * s)
		EnemyType.HOLLOW:
			# White body with a black hollow-mask face
			_draw_figure(s, Color(0.85, 0.85, 0.90), Color(0.7, 0.7, 0.8, 0.3), Color(0.0, 0.0, 0.0))
			draw_circle(Vector2(0.0, -12.0 * s), 8.0 * s, Color(0.95, 0.95, 1.0))
			draw_circle(Vector2(0.0, -12.0 * s), 6.0 * s, Color(0.10, 0.10, 0.10))
			draw_circle(Vector2(-3.0 * s, -14.0 * s), 2.0 * s, Color(0.0, 0.8, 0.0))
			draw_circle(Vector2(3.0 * s,  -14.0 * s), 2.0 * s, Color(0.0, 0.8, 0.0))
		EnemyType.ARRANCAR:
			# White coat with black hakama stripe
			_draw_figure(s, Color(0.90, 0.90, 0.95), Color(0.5, 0.5, 1.0, 0.3), Color(0.0, 0.5, 1.0))
			draw_rect(Rect2(-4.0 * s, -2.0 * s, 8.0 * s, 14.0 * s), Color(0.1, 0.1, 0.15))
		EnemyType.VILLAIN:
			_draw_figure(s, Color(0.10, 0.10, 0.30), Color(0.2, 0.0, 0.5, 0.3), Color(0.8, 0.0, 0.0))
			# Villain villain-mask / goggles
			draw_rect(Rect2(-7.0 * s, -17.0 * s, 14.0 * s, 5.0 * s), Color(0.1, 0.1, 0.2))
			draw_circle(Vector2(-3.0 * s, -14.5 * s), 2.5 * s, Color(0.6, 0.0, 0.8))
			draw_circle(Vector2(3.0 * s,  -14.5 * s), 2.5 * s, Color(0.6, 0.0, 0.8))
		EnemyType.NOMU:
			# Dark, massive body with exposed brain
			_draw_figure(s, Color(0.15, 0.10, 0.10), Color(0.3, 0.1, 0.0, 0.4), Color(0.8, 0.2, 0.0))
			draw_circle(Vector2(0.0, -20.0 * s), 9.0 * s, Color(0.8, 0.4, 0.4))
			draw_circle(Vector2(0.0, -20.0 * s), 6.0 * s, Color(0.9, 0.5, 0.5))
		EnemyType.MONSTER:
			_draw_figure(s, Color(0.60, 0.20, 0.00), Color(0.8, 0.3, 0.0, 0.4), Color(1.0, 0.8, 0.0))
		EnemyType.DRAGON_LEVEL:
			_draw_figure(s, Color(0.50, 0.00, 0.00), Color(0.9, 0.0, 0.0, 0.5), Color(1.0, 0.5, 0.0))
			# Horns
			draw_line(Vector2(-5.0 * s, -20.0 * s), Vector2(-10.0 * s, -30.0 * s),
					Color(0.6, 0.0, 0.0), 3.0 * s)
			draw_line(Vector2(5.0 * s,  -20.0 * s), Vector2(10.0 * s,  -30.0 * s),
					Color(0.6, 0.0, 0.0), 3.0 * s)
	# Gold crown on boss variants
	if is_boss:
		draw_circle(Vector2(0.0,        -28.0 * s), 5.0 * s, Color.GOLD)
		draw_circle(Vector2(-7.0 * s,  -26.0 * s), 3.0 * s, Color.GOLD)
		draw_circle(Vector2(7.0 * s,   -26.0 * s), 3.0 * s, Color.GOLD)

## Shared humanoid silhouette — body, head, eyes, arms, legs.
func _draw_figure(s: float, body: Color, glow: Color, eye: Color) -> void:
	draw_circle(Vector2.ZERO, 18.0 * s, glow)
	draw_rect(Rect2(-8.0 * s, -4.0 * s, 16.0 * s, 18.0 * s), body)
	draw_circle(Vector2(0.0, -12.0 * s), 11.0 * s, body)
	draw_circle(Vector2(-4.0 * s, -13.0 * s), 3.0 * s, eye)
	draw_circle(Vector2(4.0 * s,  -13.0 * s), 3.0 * s, eye)
	draw_circle(Vector2(-4.0 * s, -13.0 * s), 1.5 * s, Color(1.0, 0.5, 0.0))
	draw_circle(Vector2(4.0 * s,  -13.0 * s), 1.5 * s, Color(1.0, 0.5, 0.0))
	draw_line(Vector2(-8.0 * s,  2.0 * s), Vector2(-18.0 * s,  8.0 * s), body, 4.0 * s)
	draw_line(Vector2(-18.0 * s, 8.0 * s), Vector2(-22.0 * s,  4.0 * s), eye,  3.0 * s)
	draw_line(Vector2(-18.0 * s, 8.0 * s), Vector2(-21.0 * s, 12.0 * s), eye,  3.0 * s)
	draw_line(Vector2(8.0 * s,   2.0 * s), Vector2(18.0 * s,   8.0 * s), body, 4.0 * s)
	draw_line(Vector2(18.0 * s,  8.0 * s), Vector2(22.0 * s,   4.0 * s), eye,  3.0 * s)
	draw_line(Vector2(18.0 * s,  8.0 * s), Vector2(21.0 * s,  12.0 * s), eye,  3.0 * s)
	draw_rect(Rect2(-8.0 * s, 14.0 * s, 6.0 * s, 12.0 * s), body)
	draw_rect(Rect2(2.0 * s,  14.0 * s, 6.0 * s, 12.0 * s), body)
