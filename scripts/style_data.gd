extends RefCounted
class_name StyleData

const STYLE_ORDER := ["maruto", "panjiro", "itabro"]

const STYLES := {
	"maruto": {
		"path_name": "Maruto Uzumaki",
		"universe": "Village of Static Dust",
		"weapon_id": "rasengan",
		"color": Color(1.0, 0.7, 0.1),
		"levels": {
			1: {"name": "Frog Palm Orb", "desc": "A wobbling chakra orb circles you and bonks nearby threats.", "tier": "Unlock"},
			2: {"name": "Orb of Mild Panic", "desc": "Orb spin gets angrier. +damage.", "tier": "Upgrade"},
			3: {"name": "Twin Frog Trouble", "desc": "A second orbit joins the chaos.", "tier": "Upgrade"},
			4: {"name": "Swamp Blender", "desc": "The orb widens its bonk radius.", "tier": "Upgrade"},
			5: {"name": "Mega Pond Orb", "desc": "Huge orb, huge slap energy.", "tier": "Upgrade"},
			6: {"name": "Limit Break: Marsh Spiral", "desc": "Orb damage surges to ridiculous levels.", "tier": "Limit Break"},
			7: {"name": "Evolution: Frog Sage", "desc": "Triple orb formation and absurd speed.", "tier": "Evolution"},
		},
	},
	"panjiro": {
		"path_name": "Panjiro Kamabro",
		"universe": "Doodle Slayer Corps",
		"weapon_id": "water_breathing",
		"color": Color(0.2, 0.5, 1.0),
		"levels": {
			1: {"name": "Puddle Breathing", "desc": "Slash waves burst around you in all directions.", "tier": "Unlock"},
			2: {"name": "Second Form: Splash Wheel", "desc": "Sharper watery arcs. +damage.", "tier": "Upgrade"},
			3: {"name": "Third Form: Slippery Waltz", "desc": "Faster slash cadence and wider sweep.", "tier": "Upgrade"},
			4: {"name": "Whirlpool Nonsense", "desc": "More slash directions cover more space.", "tier": "Upgrade"},
			5: {"name": "Constant Splash Flux", "desc": "Cooldown drops and pressure rises.", "tier": "Upgrade"},
			6: {"name": "Limit Break: Solar Splash", "desc": "Dense slash storm with huge burst.", "tier": "Limit Break"},
			7: {"name": "Evolution: Sun Breathing-ish", "desc": "Rapid wall of blades in every lane.", "tier": "Evolution"},
		},
	},
	"itabro": {
		"path_name": "Itabro Yuuji",
		"universe": "Curseballed Academy",
		"weapon_id": "cursed_energy",
		"color": Color(0.8, 0.1, 0.9),
		"levels": {
			1: {"name": "Cursed Grape Burst", "desc": "Fan-shaped blast targets the nearest threat.", "tier": "Unlock"},
			2: {"name": "Divergent Bonk", "desc": "Extra bolt and extra sting.", "tier": "Upgrade"},
			3: {"name": "Soul Confetti", "desc": "Bolts spread wider with stronger impact.", "tier": "Upgrade"},
			4: {"name": "Body Repeal", "desc": "More bolts, more nonsense.", "tier": "Upgrade"},
			5: {"name": "1000 Mild Slaps", "desc": "Faster firing and stronger cursed push.", "tier": "Upgrade"},
			6: {"name": "Limit Break: Black Snack", "desc": "Critical cursed burst mode online.", "tier": "Limit Break"},
			7: {"name": "Evolution: Domain of Goofs", "desc": "Omnidirectional cursed storm.", "tier": "Evolution"},
		},
	},
}

const PICKUPS := {
	"heal": {
		"name": "Instant Noodle Heal",
		"desc": "Restore 30 HP right now.",
		"tier": "Pickup",
		"color": Color(0.2, 0.8, 0.3),
	},
	"speed_up": {
		"name": "Skateboard Ankles",
		"desc": "Movement speed +20%.",
		"tier": "Pickup",
		"color": Color(1.0, 0.8, 0.0),
	},
	"damage_up": {
		"name": "Spicy Power Snack",
		"desc": "All weapon damage +25%.",
		"tier": "Pickup",
		"color": Color(1.0, 0.3, 0.1),
	},
}

const TIER_COLORS := {
	"Unlock": Color(0.85, 0.85, 0.85),
	"Upgrade": Color(0.85, 0.85, 0.85),
	"Pickup": Color(0.85, 0.85, 0.85),
	"Limit Break": Color(1.0, 0.85, 0.0),
	"Evolution": Color(0.95, 0.35, 1.0),
}

static func is_style(id: String) -> bool:
	return STYLES.has(id)

static func weapon_id_for_style(style_id: String) -> String:
	return STYLES.get(style_id, {}).get("weapon_id", "")
