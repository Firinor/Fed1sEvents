local sounds = require("__base__/prototypes/entity/sounds.lua")
local Loot = {
    { item = "productivity-module-2", count_min = 1, count_max = 4, probability = 0.50 },
    { item = "productivity-module-3", count_min = 1, count_max = 3, probability = 0.25 },
    { item = "effectivity-module-2", count_min = 1, count_max = 4, probability = 0.50 },
    { item = "effectivity-module-3", count_min = 1, count_max = 3, probability = 0.25 },
    { item = "speed-module-2", count_min = 1, count_max = 4, probability = 0.50 },
    { item = "speed-module-3", count_min = 1, count_max = 3, probability = 0.25 },
    { item = "uranium-fuel-cell", count_min = 1, count_max = 1, probability = 0.10 },
}
local bzilla_verde = { r = 0, g = 1, b = 0, a = 1 }
local bzilla_verde2 = { r = 0.2, g = 0.9, b = 0.1, a = 0.75 }
local boss_hp_variant = 1
local boss_hp_multiplier = 1
local boss_dmg_multiplier = 1
local tint1 = { r = 0, g = 0, b = 1, a = 0.9 }
local tint2 = { r = 0.3, g = 0.1, b = 0.6, a = 0.8 }


local function make_biter_area_damage_level(level, radius)
    return {
        type = "area",
        radius = radius,
        force = "enemy",
        ignore_collision_condition = true,
        action_delivery = {
            type = "instant",
            target_effects = {
                {
                    type = "damage",
                    damage = { amount = (40 + level * 5), type = "physical" }
                },
                {
                    type = "create-particle",
                    repeat_count = 5,
                    particle_name = "explosion-remnants-particle",
                    initial_height = 0.5,
                    speed_from_center = 0.08,
                    speed_from_center_deviation = 0.15,
                    initial_vertical_speed = 0.08,
                    initial_vertical_speed_deviation = 0.15,
                    offset_deviation = { { -0.2, -0.2 }, { 0.2, 0.2 } }
                },
            }
        }
    }
end

function createBoss(k)
    local scale = 1.5 + k / 3

    data:extend(
            {
                { -- BLUE BITTER BOSS
                    type = "unit",
                    order = "b-b-d",
                    name = 'fed1s-boss-biter-' .. k,
                    localised_name = { "entity-name.fed1s-boss-biter" },
                    icon = "__base__/graphics/icons/behemoth-biter.png",
                    icon_size = 64, icon_mipmaps = 4,
                    flags = { "placeable-player", "placeable-enemy", "placeable-off-grid", "breaths-air", "not-repairable" },
                    max_health = (40000 * k ^ boss_hp_variant) * boss_hp_multiplier / boss_hp_variant, --max_health = 40000 * k * boss_hp_multiplier,
                    subgroup = "enemies",
                    resistances = {},
                    call_for_help_radius = 100,
                    spawning_time_modifier = 8,
                    healing_per_tick = 0.1,
                    collision_box = { { -0.1, -0.1 }, { 0.1, 0.1 } },
                    selection_box = { { -3.4, -3.4 }, { 3.4, 3.4 } },
                    distraction_cooldown = 100, -- 300,
                    loot = Loot,
                    has_belt_immunity = true,
                    attack_parameters = {
                        type = "projectile",
                        range = 1.5 + k / 2,
                        cooldown = 45 - k,
                        ammo_category = "melee",
                        sound = sounds.biter_roars(2),
                        animation = biterattackanimation(scale, tint1, tint2),
                        ammo_type = {
                            category = "melee",
                            target_type = "entity",
                            action = {
                                {
                                    action_delivery = {
                                        target_effects = {
                                            damage = {
                                                amount = (100 + k * 30) * boss_dmg_multiplier,
                                                type = "physical"
                                            },
                                            type = "damage",
                                            show_in_tooltip = true
                                        },
                                        type = "instant"
                                    },
                                    type = "direct"
                                },
                                make_biter_area_damage_level(1, scale),
                            },
                        }
                    },
                    vision_distance = 50 + k, -- 30
                    movement_speed = 0.05 + k / 100,
                    distance_per_frame = 0.3,
                    -- in pu
                    pollution_to_join_attack = 1, -- 20000
                    corpse = "fed1s-boss-bitter-corpse-" .. k,
                    dying_explosion = "blood-explosion-big",
                    working_sound = sounds.biter_calls_big(1.4),
                    dying_sound = sounds.biter_dying_big(1),
                    walking_sound = sounds.biter_walk_big(1.2),
                    running_sound_animation_positions = { 2, },
                    damaged_trigger_effect = table.deepcopy(data.raw['unit']['behemoth-biter'].damaged_trigger_effect),
                    water_reflection = biter_water_reflection(scale),
                    run_animation = biterrunanimation(scale, tint1, tint2),
                    destroy_when_commands_fail = false,
                    hide_resistances = false,
                    ai_settings = { destroy_when_commands_fail = true },
                },

                add_biter_die_animation(scale, tint1, tint2,
                        {
                            type = "corpse",
                            name = "fed1s-boss-bitter-corpse-" .. k,
                            icon = "__base__/graphics/icons/big-biter-corpse.png",
                            icon_size = 64, icon_mipmaps = 4,
                            selection_box = { { -3, -3 }, { 3, 3 } },
                            selectable_in_game = false,
                            subgroup = "corpses",
                            order = "c[corpse]-a[biter]-f[leviathan]",
                            flags = { "placeable-neutral", "placeable-off-grid", "building-direction-8-way", "not-repairable", "not-on-map" },
                        }),

                {
                    type = "unit",
                    name = "fed1s-boss-acid-spitter-" .. k,
                    localised_name = { "entity-name.fed1s-boss-spitter" },
                    icon = "__base__/graphics/icons/behemoth-spitter.png",
                    icon_size = 64, icon_mipmaps = 4,
                    flags = { "placeable-player", "placeable-enemy", "placeable-off-grid", "breaths-air", "not-repairable" },
                    max_health = (30000 * k ^ boss_hp_variant) * boss_hp_multiplier / boss_hp_variant,
                    order = "b-b-g",
                    subgroup = "enemies",
                    resistances = {},
                    healing_per_tick = 0.01,
                    collision_box = { { -0.1, -0.1 }, { 0.1, 0.1 } },
                    selection_box = { { -3.4, -3.4 }, { 3.4, 3.4 } },
                    sticker_box = { { -0.4, -0.6 }, { 0.4, 0.2 } },
                    distraction_cooldown = 100,
                    loot = Loot,
                    has_belt_immunity = true,
                    min_pursue_time = 6 * 60,
                    max_pursue_distance = 30,
                    attack_parameters = spitter_attack_parameters(
                            {
                                acid_stream_name = "fed1s-area-acid-projectile-purple", -- "jb-acid-cluster-projectile",
                                range = 60 + k * 2,
                                min_attack_distance = 10,
                                cooldown = 150 - k * 2,
                                damage_modifier = 12 + k * 4 * boss_dmg_multiplier,
                                scale = scale,
                                tint1 = bzilla_verde,
                                tint2 = bzilla_verde2,
                                roarvolume = 2
                            }),
                    call_for_help_radius = 150,
                    vision_distance = 80 + k,
                    movement_speed = 0.05 + k / 200,
                    distance_per_frame = 0.04,
                    pollution_to_join_attack = 100,
                    corpse = "fed1s-boss-acid-spitter-corpse-" .. k,
                    dying_explosion = "blood-explosion-huge",

                    working_sound = sounds.spitter_calls_big(1),
                    dying_sound = sounds.spitter_dying_big(1),
                    walking_sound = sounds.spitter_walk_big(0.9),
                    running_sound_animation_positions = { 2, },
                    damaged_trigger_effect = table.deepcopy(data.raw['unit']['behemoth-spitter'].damaged_trigger_effect),
                    water_reflection = spitter_water_reflection(scale),

                    run_animation = spitterrunanimation(scale, bzilla_verde, bzilla_verde2),
                    destroy_when_commands_fail = false,
                    hide_resistances = false,
                    ai_settings = { destroy_when_commands_fail = false }
                },


                -- CORPSES SPITTERS
                add_spitter_die_animation(scale, bzilla_verde, bzilla_verde2,
                        {
                            type = "corpse",
                            name = "fed1s-boss-acid-spitter-corpse-" .. k,
                            icon = "__base__/graphics/icons/big-biter-corpse.png",
                            icon_size = 64, icon_mipmaps = 4,
                            selectable_in_game = false,
                            selection_box = { { -4, -4 }, { 4, 4 } },
                            subgroup = "corpses",
                            order = "c[corpse]-b[spitter]-f[leviathan]",
                            flags = { "placeable-neutral", "placeable-off-grid", "building-direction-8-way", "not-on-map" },
                            dying_speed = 0.01,
                        }),
            })
end

createBoss(1)