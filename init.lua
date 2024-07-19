-- travelnet_redo_beacons/init.lua
-- Travelnet components in Telemosaic style
-- Copyright (C) 2015-2024  mt-mods members and contributors
-- Copyright (C) 2024  1F616EMO
-- SPDX-License-Identifier: GPL-3.0-or-later

local S = minetest.get_translator("travelnet_redo_beacons")

local def = {
    description = S("Travelnet Bracon"),
    tiles = { "travelnet_redo_beacons_top.png", "travelnet_redo_beacons_side.png" },

    paramtype = "light",
    groups = { cracky = 3, pickaxey = 1, transport = 1, travelnet_redo_beacons = 1 },
    is_ground_content = false,

    node_placement_prediction = "travelnet_redo_beacons:beacon_off",

    on_construct = function(pos)
        local node = minetest.get_node(pos)
        node.name = "travelnet_redo_beacons:beacon_off"
        minetest.swap_node(pos, node)
    end,

    _travelnet_on_teleport = function(travelnet, _, player)
        local old_pos = player:get_pos()
        local new_pos = travelnet.pos

        print(minetest.pos_to_string(old_pos), minetest.pos_to_string(new_pos))

        player:set_pos(vector.add(new_pos, vector.new(0, 0.5, 0)))
        player:set_look_vertical(math.pi * 10 / 180) -- don't face down

        do
            local sound_param = { pos = old_pos, max_hear_distance = 30 }
            if vector.distance(old_pos, new_pos) > 30 then
                sound_param.exclude_player = player:get_player_name()
            end
            minetest.sound_play({ name = "travelnet_redo_beacons_departure", gain = 1 }, sound_param)
        end

        minetest.sound_play(
            { name = "travelnet_redo_beacons_arrival", gain = 1 },
            { pos = new_pos, max_hear_distance = 30 })

        minetest.add_particlespawner({
            amount = 100,
            time = 0.25,
            minpos = vector.add(old_pos, vector.new(0, 0.3, 0)),
            maxpos = vector.add(old_pos, vector.new(0, 2, 0)),
            minvel = { x = 1, y = -6, z = 1 },
            maxvel = { x = -1, y = -1, z = -1 },
            minacc = { x = 0, y = -2, z = 0 },
            maxacc = { x = 0, y = -6, z = 0 },
            minexptime = 0.1,
            minsize = 0.5,
            maxsize = 1.5,
            texture = "travelnet_redo_beacons_particle_departure.png",
            glow = 15,
        })

        minetest.add_particlespawner({
            amount = 100,
            time = 0.25,
            minpos = vector.add(new_pos, vector.new(0, 0.3, 0)),
            maxpos = vector.add(new_pos, vector.new(0, 2, 0)),
            minvel = { x = -1, y = 1, z = -1 },
            maxvel = { x = 1, y = 6, z = 1 },
            minacc = { x = 0, y = -2, z = 0 },
            maxacc = { x = 0, y = -6, z = 0 },
            minexptime = 0.1,
            minsize = 0.5,
            maxsize = 1.5,
            texture = "travelnet_redo_beacons_particle_arrival.png",
            glow = 15,
        })
    end,
}

travelnet_redo.register_travelnet("travelnet_redo_beacons:beacon", table.copy(def))

def.description = nil
def.on_construct = nil
def.node_placement_prediction = nil
def.drop = "travelnet_redo_beacons:beacon"
def.groups.not_in_creative_inventory = 1
def.tiles[1] = "travelnet_redo_beacons_off.png"
def._tvnet_on_setup = function(travelnet, network, node)
    travelnet_redo.default_on_setup(travelnet, network, node)

    node.name = "travelnet_redo_beacons:beacon"
    minetest.swap_node(travelnet.pos, node)
end

travelnet_redo.register_travelnet("travelnet_redo_beacons:beacon_off", table.copy(def))

-- Waiting for xcompat to have obsidian
minetest.register_craft({
    output = "travelnet_redo_beacons:beacon",
    recipe = {
        { "default:diamond",  "default:mese", "default:diamond" },
        { "default:obsidian", "default:mese", "default:obsidian" }
    }
})

minetest.register_abm({
    label = "Travelnet Beacon effect",
    nodenames = { "travelnet_redo_beacons:beacon" },
    interval = 2.0,
    chance = 2,
    catch_up = false,
    action = function(pos)
        minetest.add_particlespawner({
            amount = 4,
            time = 2,
            minpos = vector.add(pos, vector.new(-0.2, 0, -0.2)),
            maxpos = vector.add(pos, vector.new(0.2, 0, 0.2)),
            minvel = { x = 0, y = 1, z = 0 },
            maxvel = { x = 0, y = 2, z = 0 },
            maxexptime = 2,
            maxsize = 1.7,
            texture = "travelnet_redo_beacons_particle_arrival.png",
            glow = 9
        })
    end
})
