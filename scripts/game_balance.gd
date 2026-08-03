extends RefCounted
class_name GameBalance

const PLAYER := {
	"base_speed": 200.0,
	"dash_speed": 560.0,
	"dash_duration": 0.2,
	"dash_cooldown": 1.2,
	"graze_radius": 62.0,
	"hurtbox_radius": 14.0,
}

const SINGLE := {
	"wave_spawn_min": 480.0,
	"wave_spawn_max": 720.0,
	"base_enemies": 5,
	"per_wave_add": 3,
	"health_growth": 0.25,
	"speed_growth_after_wave": 3,
	"speed_growth": 8.0,
	"spawn_interval_start": 0.5,
	"spawn_interval_delta": 0.03,
	"spawn_interval_floor": 0.15,
	"elite_every": 5,
}

const MULTI := {
	"rival_count": 7,
	"arena_start_radius": 1100.0,
	"arena_end_radius": 220.0,
	"zone_shrink_time": 150.0,
	"zone_tick_damage": 12.0,
	"zone_tick_interval": 0.5,
}

const ENEMY := {
	"bullet_speed": 220.0,
	"bullet_damage": 8.0,
	"attack_min_cd": 1.1,
	"attack_max_cd": 2.2,
	"telegraph_time": 0.35,
	"safe_gap_bullets": 1,
}

const UI := {
	"multiplayer_mode_label": "LMS BATTLE",
	"single_mode_label": "WAVE SURVIVAL",
}
