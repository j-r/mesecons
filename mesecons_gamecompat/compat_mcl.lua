
--Aliases

minetest.register_alias("mesecons_gamecompat:chest", "mcl_chests:chest")
minetest.register_alias("mesecons_gamecompat:chest_locked", "mcl_chests:chest")
minetest.register_alias("mesecons_gamecompat:coalblock", "mcl_core:coalblock")
minetest.register_alias("mesecons_gamecompat:cobble", "mcl_core:cobble")
minetest.register_alias("mesecons_gamecompat:glass", "mcl_core:glass")
minetest.register_alias("mesecons_gamecompat:lava_source", "mcl_core:lava_source")
minetest.register_alias("mesecons_gamecompat:mese", "mesecons:redstoneblock")
minetest.register_alias("mesecons_gamecompat:mese_crystal", "mesecoms:redstone")
minetest.register_alias("mesecons_gamecompat:mese_crystal_fragment", "mesecons:redstone")
minetest.register_alias("mesecons_gamecompat:obsidian_glass", "mcl_core:glass")
minetest.register_alias("mesecons_gamecompat:stone", "mcl_core:stone")
minetest.register_alias("mesecons_gamecompat:steel_ingot", "mcl_core:iron_ingot")
minetest.register_alias("mesecons_gamecompat:steelblock", "mcl_core:steelblock")
minetest.register_alias("mesecons_gamecompat:torch", "mcl_torches:torch")

if minetest.get_modpath("mcl_dyes") then
	for color, def in ipairs(mcl_dyes.colors) do
		minetest.register_alias("mesecons_gamecompat:dye_" .. def.mcl2, "mcl_dyes:" .. color)
	end
end

-- Sounds

mesecon.node_sound.default = mcl_sounds.node_sound_defaults()
mesecon.node_sound.glass = mcl_sounds.node_sound_glass_defaults()
mesecon.node_sound.leaves = mcl_sounds.node_sound_leaves_defaults()
mesecon.node_sound.stone = mcl_sounds.node_sound_stone_defaults()
mesecon.node_sound.wood = mcl_sounds.node_sound_wood_defaults()

if minetest.get_modpath("mcl_fire") then
	mesecon.sound_name.fire = "fire_fire"
end

if minetest.get_modpath("mcl_tnt") then
	mesecon.sound_name.explode = "tnt_explode"
end

-- Textures

mesecon.texture.steel_block = "default_steel_block.png"

-- MCLA redstone interoperability

if minetest.get_modpath("mcl_redstone") then
	local rules = mesecon.rules.alldirs
	local redstone = {
		connects_to = function(node)
			return true
		end,
		get_power = function(node)
			return (node.param2 >= 128) and 15 or 0
		end,
		update = function(pos, node)
			if node.param2 >= 128 then return end

			local def = minetest.registered_nodes[node.name]
			local oldpowered = def.__mesecon_state == "on"
			local powered = mcl_redstone.get_power(pos, nil, "direct") ~= 0
			if powered and not oldpowered then
				mesecon.flipstate(pos, node)
				mesecon.receptor_on(pos, rules)
			elseif not powered and oldpowered then
				mesecon.flipstate(pos, node)
				mesecon.receptor_off(pos, rules)
			end
		end,
	}

	mesecon.register_node("mesecons_gamecompat:converter", {
		description = "Converter",
		tiles = {"default_dirt.png"},
		groups = {handy=1, axey=1, material_wood=1, flammable=-1},
		sunlight_propagates = true,
		is_ground_content = false,
		paramtype = "light",
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = { -6/16, -6/16, -6/16, 6/16, 6/16, 6/16 },
		},
		_mcl_redstone = redstone,
	}, {
		mesecons = {
			receptor = {
				state = mesecon.state.off,
				rules = rules,
			},
			effector = {
				rules = rules,
				action_on = function(pos, node)
					node.param2 = node.param2 % 128 + 128
					mcl_redstone.swap_node(vector.copy(pos), node)
				end,
				action_off = function(pos, node)
					node.param2 = node.param2 % 128
					mcl_redstone.swap_node(vector.copy(pos), node)
				end
			}
		},
	}, {
		mesecons = {
			receptor = {
				state = mesecon.state.on,
				rules = rules,
			},
		},
	})
end
