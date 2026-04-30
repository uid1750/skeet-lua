--- @qhouz

local ffi = require "ffi";
local merge = table.concat;

--- constants
local MATERIALS = {
    ["2015 glass"]           = "models/inventory_items/service_medal_2015/glass",
    ["2016 glass"]           = "models/inventory_items/service_medal_2016/glass_lvl4",
    ["Branches"]             = "models/props_foliage/urban_tree03_branches",
    ["Charset color"]        = "models/inventory_items/contributor_map_tokens/contributor_charset_color",
    ["Cologne glass"]        = "models/inventory_items/cologne_prediction/cologne_prediction_glass",
    ["Crystal blue"]         = "models/inventory_items/trophy_majors/crystal_blue",
    ["Crystal clear"]        = "models/inventory_items/trophy_majors/crystal_clear",
    ["Dogtag outline"]       = "models/inventory_items/dogtags/dogtags_outline",
    ["Dogtag light"]         = "models/inventory_items/dogtags/dogtags_lightray",
    ["Dogstags"]             = "models/inventory_items/dogtags/dogtags",
    ["ESL_C"]                = "models/weapons/customization/stickers/cologne2014/esl_c",
    ["FBI Glass"]            = "models/player/ct_fbi/ct_fbi_glass",
    ["Fishnet"]              = "models/props_shacks/fishing_net01",
    ["Gold"]                 = "models/inventory_items/trophy_majors/gold",
    ["Glass"]                = "models/gibs/glass/glass",
    ["Gloss"]                = "models/inventory_items/trophy_majors/gloss",
    ["Glow"]                 = "vgui/achievements/glow",
    ["Guerilla"]             = "models/player/t_guerilla/t_guerilla",
    ["Hydra crystal"]        = "models/inventory_items/hydra_crystal/hydra_crystal",
    ["Hydra crystal detail"] = "models/inventory_items/hydra_crystal/hydra_crystal_detail",
    ["MP3 detail"]           = "models/inventory_items/music_kit/darude_01/mp3_detail",
    ["Major gloss"]          = "models/inventory_items/trophy_majors/gloss",
    ["Silver winners"]       = "models/inventory_items/trophy_majors/silver_winners",
    ["Velvet"]               = "models/inventory_items/trophy_majors/velvet",
    ["Wildfire gold"]        = "models/inventory_items/wildfire_gold/wildfire_gold_detail",
}

local MATERIAL_VAR_FLAGS = {
    ["DEBUG"]                    = 0,
    ["NO_DEBUG_OVERRIDE"]        = 1,
    ["NO_DRAW"]                  = 2,
    ["USE_IN_FILLRATE_MODE"]     = 3,
    ["VERTEXCOLOR"]              = 4,
    ["VERTEXALPHA"]              = 5,
    ["SELFILLUM"]                = 6,
    ["ADDITIVE"]                 = 7,
    ["ALPHATEST"]                = 8,
    ["MULTIPASS"]                = 9,
    ["ZNEARER"]                  = 10,
    ["MODEL"]                    = 11,
    ["FLAT"]                     = 12,
    ["NOCULL"]                   = 13,
    ["NOFOG"]                    = 14,
    ["IGNOREZ"]                  = 15,
    ["DECAL"]                    = 16,
    ["ENVMAPSPHERE"]             = 17,
    ["NOALPHAMOD"]               = 18,
    ["ENVMAPCAMERASPACE"]        = 19,
    ["BASEALPHAENVMAPMASK"]      = 20,
    ["TRANSLUCENT"]              = 21,
    ["NORMALMAPALPHAENVMAPMASK"] = 22,
    ["NEEDS_SOFTWARE_SKINNING"]  = 23,
    ["OPAQUETEXTURE"]            = 24,
    ["ENVMAPMODE"]               = 25,
    ["SUPPRESS_DECALS"]          = 26,
    ["HALFLAMBERT"]              = 27,
    ["WIREFRAME"]                = 28,
    ["ALLOWALPHATOCOVERAGE"]     = 29,
    ["IGNORE_ALPHA"]             = 30,
    ["VERTEXFOG"]                = 31
};

local MATERIAL_FLAGS = {
    ["Additive"]  = "ADDITIVE",
    ["Ignore-Z"]  = "IGNOREZ",
    ["No draw"]   = "NO_DRAW",
    ["No cull"]   = "NOCULL",
    ["Wireframe"] = "WIREFRAME"
};

--- enumerations
local e_materials = {
    [0]  = "2015 glass",
    [1]  = "2016 glass",
    [2]  = "Branches",
    [3]  = "Charset color",
    [4]  = "Cologne glass",
    [5]  = "Crystal blue",
    [6]  = "Crystal clear",
    [7]  = "Dogtag outline",
    [8]  = "Dogtag light",
    [9]  = "Dogstags",
    [10] = "ESL_C",
    [11] = "FBI Glass",
    [12] = "Fishnet",
    [13] = "Gold",
    [14] = "Glass",
    [15] = "Gloss",
    [16] = "Glow",
    [17] = "Guerilla",
    [18] = "Hydra crystal",
    [19] = "Hydra crystal detail",
    [20] = "MP3 detail",
    [21] = "Major gloss",
    [22] = "Silver winners",
    [23] = "Velvet",
    [24] = "Wildfire gold"
};

local e_material_var_flags = {
    [0]  = "DEBUG",
    [1]  = "NO_DEBUG_OVERRIDE",
    [2]  = "NO_DRAW",
    [3]  = "USE_IN_FILLRATE_MODE",
    [4]  = "VERTEXCOLOR",
    [5]  = "VERTEXALPHA",
    [6]  = "SELFILLUM",
    [7]  = "ADDITIVE",
    [8]  = "ALPHATEST",
    [9]  = "MULTIPASS",
    [10] = "ZNEARER",
    [11] = "MODEL",
    [12] = "FLAT",
    [13] = "NOCULL",
    [14] = "NOFOG",
    [15] = "IGNOREZ",
    [16] = "DECAL",
    [17] = "ENVMAPSPHERE",
    [18] = "NOALPHAMOD",
    [19] = "ENVMAPCAMERASPACE",
    [20] = "BASEALPHAENVMAPMASK",
    [21] = "TRANSLUCENT",
    [22] = "NORMALMAPALPHAENVMAPMASK",
    [23] = "NEEDS_SOFTWARE_SKINNING",
    [24] = "OPAQUETEXTURE",
    [25] = "ENVMAPMODE",
    [26] = "SUPPRESS_DECALS",
    [27] = "HALFLAMBERT",
    [28] = "WIREFRAME",
    [29] = "ALLOWALPHATOCOVERAGE",
    [30] = "IGNORE_ALPHA",
    [31] = "VERTEXFOG"
};

local e_material_flags = {
    [0] = "Additive",
    [1] = "Ignore-Z",
    [2] = "No draw",
    [3] = "No cull",
    [4] = "Wireframe"
};

local utils = { };
local iinput = { };
local software = { };
local override = { };
local chams = { };

--- region utils
do
    function utils.includes(list, value)
        for i = 1, #list do
            if list[i] == value then
                return i;
            end
        end

        return nil;
    end

    function utils.find_signature(module_name, pattern, offset)
        local match = client.find_signature(module_name, pattern);

        if match == nil then
            return nil;
        end

        if offset ~= nil then
            local address = ffi.cast("char*", match);
            address = address + offset;

            return address;
        end

        return match;
    end
end

--- region software
do
    software.weapon_viewmodel = { ui.reference("Visuals", "Colored models", "Weapon viewmodel") };
end

--- region iinput
do
    local SIGNATURE = {
        "client.dll",
        "\xB9\xCC\xCC\xCC\xCC\x8B\x40\x38\xFF\xD0\x84\xC0\x0F\x85",
        1
    };

    local address = utils.find_signature(unpack(SIGNATURE));
    local iface = ffi.cast("uintptr_t***", address)[0];

    local native_CAM_IsThirdPerson = ffi.cast("bool(__thiscall*)(void*, int nSlot)", iface[0][32]);

    function iinput.is_third_person(slot)
        slot = slot or -1;

        return native_CAM_IsThirdPerson(iface, slot);
    end
end

--- region override
do
    local data = { };

    function override.get(ref)
        if data[ref] == nil then
            return;
        end

        return unpack(data[ref]);
    end

    function override.set(ref, ...)
        if data[ref] == nil then
            data[ref] = { ui.get(ref) };
        end

        ui.set(ref, ...);
    end

    function override.unset(ref)
        if data[ref] == nil then
            return;
        end

        ui.set(ref, unpack(data[ref]));
        data[ref] = nil;
    end
end

--- region chams
do
    local data = { };
    local used_materials = { };

    local prev_idx;
    local prev_team;
    local prev_third_person;

    local lasttime = 0;
    local force_update = false;

    local enabled = ui.new_checkbox("Visuals", "Colored models", "Weapon viewmodel chams");
    local config_slot = ui.new_string("me.allure.chams", "\0");

    local remember_weapons = ui.new_checkbox("Visuals", "Colored models", "Remember weapons");
    local show_weapon_viewmodel = ui.new_multiselect("Visuals", "Colored models", "Show weapon viewmodel", { "First person", "Third person" });

    local viewmodel_override = ui.new_checkbox("Visuals", "Colored models", "Weapon viewmodel override");
    local viewmodel_color = ui.new_color_picker("Visuals", "Colored models", "Weapon viewmodel color", 50, 16, 110);
    local viewmodel_material = ui.new_combobox("Visuals", "Colored models", merge { "\n", "Weapon viewmodel material" }, { "Default", "Solid", "Shaded", "Metallic", "Glow", "Bubble", "Original" });
    local viewmodel_material_color = ui.new_color_picker("Visuals", "Colored models", "Weapon viewmodel material color", 84, 158, 164);

    local material_override = ui.new_checkbox("Visuals", "Colored models", "Material override");
    local material_color = ui.new_color_picker("Visuals", "Colored models", "Material color", 255, 0, 0);
    local material_selection = ui.new_combobox("Visuals", "Colored models", merge { "\n", "Material selection" }, { unpack(e_materials, 0) });
    local material_flags = ui.new_multiselect("Visuals", "Colored models", merge { "\n", "Material flags" }, { unpack(e_material_flags, 0) });

    local material_properties = ui.new_checkbox("Visuals", "Colored models", "Material properties");
    local material_size = ui.new_slider("Visuals", "Colored models", "Material size", 1, 100, 1);
    local animation_speed = ui.new_slider("Visuals", "Colored models", "Animation speed", 1, 10, 5);
    local animation_framerate = ui.new_slider("Visuals", "Colored models", "Animation framerate", 1, 144, 30);

    ui.set(viewmodel_material, "Metallic");

    local function get_team_num(ent)
        local m_iTeamNum = entity.get_prop(ent, "m_iTeamNum");

        if m_iTeamNum == 0 then return end
        if m_iTeamNum == 1 then return end

        return m_iTeamNum;
    end

    local function get_definition_index(ent)
        return bit.band(entity.get_prop(ent, "m_iItemDefinitionIndex"), 0xFFFF);
    end

    local function get_weapon_viewmodel(me, wpn, is_third_person)
        if wpn == nil then
            return;
        end

        if is_third_person then
            return entity.get_prop(wpn, "m_hWeaponWorldModel");
        end

        return entity.get_prop(me, "m_hViewModel[0]");
    end

    local function get_weapon_materials(me, wpn, is_third_person)
        local entindex = get_weapon_viewmodel(me, wpn, is_third_person);

        if entindex == nil then
            return { };
        end

        return materialsystem.get_model_materials(entindex);
    end

    local function get_settings()
        local list = { };

        list.show_weapon_viewmodel = ui.get(show_weapon_viewmodel);

        list.viewmodel_override = ui.get(viewmodel_override);
        list.viewmodel_color = { ui.get(viewmodel_color) };
        list.viewmodel_material = ui.get(viewmodel_material);
        list.viewmodel_material_color = { ui.get(viewmodel_material_color) };

        list.material_override = ui.get(material_override);
        list.material_color = { ui.get(material_color) };
        list.material_selection = ui.get(material_selection);
        list.material_flags = ui.get(material_flags);

        list.material_properties = ui.get(material_properties);
        list.material_size = ui.get(material_size);
        list.animation_speed = ui.get(animation_speed);
        list.animation_framerate = ui.get(animation_framerate);

        return list;
    end

    local function set_settings(list)
        ui.set(show_weapon_viewmodel, list.show_weapon_viewmodel);

        ui.set(viewmodel_override, list.viewmodel_override);
        ui.set(viewmodel_color, unpack(list.viewmodel_color));
        ui.set(viewmodel_material, list.viewmodel_material);
        ui.set(viewmodel_material_color, unpack(list.viewmodel_material_color));

        ui.set(material_override, list.material_override);
        ui.set(material_color, unpack(list.material_color));
        ui.set(material_selection, list.material_selection);
        ui.set(material_flags, list.material_flags);

        ui.set(material_properties, list.material_properties);
        ui.set(material_size, list.material_size);
        ui.set(animation_speed, list.animation_speed);
        ui.set(animation_framerate, list.animation_framerate);
    end

    local function reset_materials()
        for material in pairs(used_materials) do
            material:reload();
            used_materials[material] = nil;
        end
    end

    local function update_settings(wpn_idx)
        if not ui.get(remember_weapons) then
            return;
        end

        local old_idx = tostring(prev_idx);
        local new_idx = tostring(wpn_idx);

        if prev_idx ~= nil then
            data[old_idx] = get_settings();
        end

        local new_info = data[new_idx];
        force_update = true;

        if new_info == nil then
            ui.set(show_weapon_viewmodel, { });

            ui.set(viewmodel_override, false);
            ui.set(viewmodel_color, 50, 16, 110, 255);
            ui.set(viewmodel_material, "Metallic");
            ui.set(viewmodel_material_color, 84, 158, 164, 255);

            ui.set(material_override, false);
            ui.set(material_color, 255, 0, 0, 255);
            ui.set(material_selection, e_materials[0]);
            ui.set(material_flags, { });

            ui.set(material_properties, false);
            ui.set(material_size, 1);
            ui.set(animation_speed, 5);
            ui.set(animation_framerate, 30);

            return;
        end

        set_settings(new_info);
    end

    local function update_config()
        local me = entity.get_local_player();
        if me == nil then return end
        local wpn = entity.get_player_weapon(me);
        if wpn == nil then return end

        local wpn_idx = get_definition_index(wpn);
        if wpn_idx == nil then return end

        local info = data[tostring(wpn_idx)];
        if info == nil then return end

        set_settings(info);
    end

    local function update_materials(me, wpn, is_third_person)
        local materials = get_weapon_materials(me, wpn, is_third_person);
        if next(materials) == nil then return end

        local flags = ui.get(material_flags);
        local r, g, b, a = ui.get(material_color);

        local show_weapon_viewmodel_value = ui.get(show_weapon_viewmodel);

        local is_changing_properties = ui.get(material_properties);
        local is_overriding_material = ui.get(material_override);
        local is_overriding_viewmodel = ui.get(viewmodel_override);
        local is_displaying_material = false;

        if not is_third_person and utils.includes(show_weapon_viewmodel_value, "First person") then
            is_displaying_material = true;
        end

        if is_third_person and utils.includes(show_weapon_viewmodel_value, "Third person") then
            is_displaying_material = true;
        end

        local new_material;

        if is_overriding_material then
            local material_name = ui.get(material_selection);
            local material_path = MATERIALS[material_name];

            new_material = materialsystem.find_material(material_path, true);
        end

        if is_overriding_viewmodel then
            override.set(software.weapon_viewmodel[1], is_displaying_material);
            override.set(software.weapon_viewmodel[2], ui.get(viewmodel_color));
            override.set(software.weapon_viewmodel[3], ui.get(viewmodel_material));
            override.set(software.weapon_viewmodel[4], ui.get(viewmodel_material_color));
        else
            override.unset(software.weapon_viewmodel[1]);
            override.unset(software.weapon_viewmodel[2]);
            override.unset(software.weapon_viewmodel[3]);
            override.unset(software.weapon_viewmodel[4]);
        end

        if force_update then
            for i = 1, #materials do
                local material = materials[i];

                if is_displaying_material and new_material ~= nil then
                    used_materials[material] = true;

                    for j = 0, #e_material_var_flags do
                        material:set_material_var_flag(j, new_material:get_material_var_flag(j));
                    end

                    material:set_shader_param(6, new_material:get_shader_param(6));
                    material:set_shader_param("$phong", 0);

                    for j = 1, #flags do
                        local flag = flags[j];

                        local flag_var = MATERIAL_FLAGS[flag];
                        local flag_num = MATERIAL_VAR_FLAGS[flag_var];

                        material:set_material_var_flag(flag_num, true);
                    end

                    material:color_modulate(r, g, b);
                    material:alpha_modulate(a);

                    if not is_changing_properties then
                        material:set_shader_param("$basetexturetransform", 1, 1, 1);
                    end

                    goto continue;
                end

                material:reload();
                used_materials[material] = nil;

                ::continue::
            end
        end

        if is_displaying_material and is_changing_properties and new_material ~= nil then
            local framerate = 1 / ui.get(animation_framerate);

            local realtime = globals.realtime();
            local deltatime = realtime - lasttime;

            if deltatime >= framerate then
                local size = ui.get(material_size);
                local speed = ui.get(animation_speed);

                local time = realtime * (speed * 0.1);

                for i = 1, #materials do
                    local material = materials[i];

                    material:set_shader_param("$basetexturetransform", size, time, time);
                    material:set_shader_param("$reflectivity", 0.0, 0.0, 0.0);
                    material:set_shader_param("$phong", 0);
                end

                lasttime = realtime;
            end
        end
    end

    local function update_menu()
        if not ui.get(enabled) then
            ui.set_visible(show_weapon_viewmodel, false);

            ui.set_visible(viewmodel_override, false);
            ui.set_visible(viewmodel_color, false);
            ui.set_visible(viewmodel_material, false);
            ui.set_visible(viewmodel_material_color, false);

            ui.set_visible(material_override, false);
            ui.set_visible(material_color, false);
            ui.set_visible(material_selection, false);
            ui.set_visible(material_flags, false);

            ui.set_visible(material_properties, false);
            ui.set_visible(material_size, false);
            ui.set_visible(animation_speed, false);
            ui.set_visible(animation_framerate, false);

            override.unset(software.weapon_viewmodel[1]);
            override.unset(software.weapon_viewmodel[2]);
            override.unset(software.weapon_viewmodel[3]);
            override.unset(software.weapon_viewmodel[4]);

            reset_materials();
            return;
        end

        local is_changing_properties = ui.get(material_properties);
        local is_overriding_material = ui.get(material_override);
        local is_overriding_viewmodel = ui.get(viewmodel_override);

        if not is_overriding_viewmodel then
            override.unset(software.weapon_viewmodel[1]);
            override.unset(software.weapon_viewmodel[2]);
            override.unset(software.weapon_viewmodel[3]);
            override.unset(software.weapon_viewmodel[4]);
        end

        if not is_overriding_material then
            reset_materials();
        end

        ui.set_visible(show_weapon_viewmodel, true);

        ui.set_visible(viewmodel_override, true);
        ui.set_visible(viewmodel_color, true);
        ui.set_visible(viewmodel_material, is_overriding_viewmodel);
        ui.set_visible(viewmodel_material_color, is_overriding_viewmodel);

        ui.set_visible(material_override, true);
        ui.set_visible(material_color, true);
        ui.set_visible(material_selection, is_overriding_material);
        ui.set_visible(material_flags, is_overriding_material);

        ui.set_visible(material_properties, is_overriding_material);
        ui.set_visible(material_size, is_overriding_material);
        ui.set_visible(animation_speed, is_overriding_material);
        ui.set_visible(animation_framerate, is_overriding_material);

        ui.set_enabled(material_properties, true);
        ui.set_enabled(material_size, is_changing_properties);
        ui.set_enabled(animation_speed, is_changing_properties);
        ui.set_enabled(animation_framerate, is_changing_properties);

        force_update = true;
    end

    local function load_data()
        local value = ui.get(config_slot);
        if value == "\0" then return end

        local subject = json.parse(value);
        data = subject or { };
    end

    local function save_data()
        local me = entity.get_local_player();
        if me == nil then return end

        local wpn = entity.get_player_weapon(me);
        if wpn == nil then return end

        local wpn_idx = get_definition_index(wpn);
        if wpn_idx == nil then return end

        data[tostring(wpn_idx)] = get_settings();
        ui.set(config_slot, json.stringify(data));
    end

    function chams.shutdown()
        reset_materials();
        save_data();
    end

    function chams.pre_config_save()
        override.unset(software.weapon_viewmodel[1])
        save_data();
    end

    function chams.post_config_load()
        reset_materials();

        load_data();
        update_config();
    end

    function chams.pre_render()
        if not ui.get(enabled) then
            return;
        end

        local me = entity.get_local_player();
        if me == nil then return end

        local team = get_team_num(me);
        if team == nil then return end

        local wpn = entity.get_player_weapon(me);
        if wpn == nil then return end

        local wpn_idx = get_definition_index(wpn);
        if wpn_idx == nil then return end

        if prev_idx ~= wpn_idx or prev_team ~= team then
            update_settings(wpn_idx, team);
        end

        local is_third_person = iinput.is_third_person();

        if prev_third_person ~= is_third_person then
            force_update = true;
        end

        update_materials(me, wpn, is_third_person);

        force_update = false;

        prev_idx = wpn_idx;
        prev_team = team;
        prev_third_person = is_third_person;
    end

    ui.set_callback(enabled, update_menu);

    ui.set_callback(show_weapon_viewmodel, update_menu);

    ui.set_callback(viewmodel_override, update_menu);
    ui.set_callback(viewmodel_color, update_menu);
    ui.set_callback(viewmodel_material, update_menu);
    ui.set_callback(viewmodel_material_color, update_menu);

    ui.set_callback(material_override, update_menu);
    ui.set_callback(material_color, update_menu);
    ui.set_callback(material_selection, update_menu);
    ui.set_callback(material_flags, update_menu);

    ui.set_callback(material_properties, update_menu);
    ui.set_callback(material_size, update_menu);
    ui.set_callback(animation_speed, update_menu);
    ui.set_callback(animation_framerate, update_menu);

    client.delay_call(0, function()
        load_data();
        update_config();
    end);

    update_menu();
end

client.set_event_callback("shutdown", chams.shutdown);

client.set_event_callback("pre_config_save", chams.pre_config_save);
client.set_event_callback("post_config_load", chams.post_config_load);

client.set_event_callback("pre_render", chams.pre_render);