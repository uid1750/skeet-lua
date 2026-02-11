local ffi = require "ffi"

local bit_band, bit_bnot, bit_bor, bit_lshift = bit.band, bit.bnot, bit.bor, bit.lshift
local ui_get, ui_new_combobox, ui_reference = ui.get, ui.new_combobox, ui.reference
local client_set_event_callback, client_find_signature = client.set_event_callback, client.find_signature
local entity_get_local_player, entity_get_prop = entity.get_local_player, entity.get_prop

ffi.cdef [[
    typedef struct {
        float x;
        float y;
        float z;
    } vector_t;

    typedef struct {
        void     *vfptr;
        int      command_number;
        int      tickcount;
        vector_t viewangles;
        vector_t aimdirection;
        float    forwardmove;
        float    sidemove;
        float    upmove;
        int      buttons;
        uint8_t  impulse;
        int      weaponselect;
        int      weaponsubtype;
        int      random_seed;
        short    mousedx;
        short    mousedy;
        bool     hasbeenpredicted;
        vector_t headangles;
        vector_t headoffset;
        char	 pad_0x4C[0x18];
    } cusercmd_t;
]]

local IN_FORWARD   = bit_lshift(1, 3)
local IN_BACK      = bit_lshift(1, 4)
local IN_MOVELEFT  = bit_lshift(1, 9)
local IN_MOVERIGHT = bit_lshift(1, 10)

local quick_peek_assist_ref = { ui_reference("Rage", "Other", "Quick peek assist") }
local leg_movement_ref = ui_reference("AA", "Other", "Leg movement")

local quick_peek_mode = ui_new_combobox("AA", "Other", "legs on autopeek", { "Off", "Always slide", "Never slide" })

local iinput = {}

do
    local function find_signature(module_name, pattern, offset)
        local match = client_find_signature(module_name, pattern)

        if match == nil then
            return nil
        end

        if offset ~= nil then
            local address = ffi.cast("char*", match)
            address = address + offset

            return address
        end

        return match
    end

    local address = find_signature("client.dll", "\xB9\xCC\xCC\xCC\xCC\x8B\x40\x38\xFF\xD0\x84\xC0\x0F\x85", 1)
    local iface = ffi.cast("uintptr_t***", address)[0]

    local native_GetUserCmd = ffi.cast("cusercmd_t*(__thiscall*)(void*, int nSlot, int sequence_number)", iface[0][8])

    function iinput.get_usercmd(slot, command_number)
        if command_number == 0 then
            return nil
        end

        return native_GetUserCmd(iface, slot, command_number)
    end
end

local function always_slide(cmd)
    cmd.buttons = bit_bor(cmd.buttons, cmd.forwardmove > 0 and IN_BACK or IN_FORWARD)
    cmd.buttons = bit_bor(cmd.buttons, cmd.sidemove > 0 and IN_MOVERIGHT or IN_MOVELEFT)
    cmd.buttons = bit_band(cmd.buttons, bit_bnot(cmd.forwardmove > 0 and IN_FORWARD or IN_BACK))
    cmd.buttons = bit_band(cmd.buttons, bit_bnot(cmd.sidemove > 0 and IN_MOVELEFT or IN_MOVERIGHT))
end

local function never_slide(cmd)
    cmd.buttons = bit_band(cmd.buttons, bit_bnot(IN_FORWARD))
    cmd.buttons = bit_band(cmd.buttons, bit_bnot(IN_BACK))
    cmd.buttons = bit_band(cmd.buttons, bit_bnot(IN_MOVELEFT))
    cmd.buttons = bit_band(cmd.buttons, bit_bnot(IN_MOVERIGHT))
end

local function on_finish_command(e)
    local me = entity_get_local_player()
    
    if me == nil then
        return
    end

    local movetype = entity_get_prop(me, "m_movetype")
    
    if movetype ~= 2 then
        return
    end

    if not ui_get(quick_peek_assist_ref[1]) or not ui_get(quick_peek_assist_ref[2]) then
        return
    end

    local cmd = iinput.get_usercmd(0, e.command_number)
    
    if cmd == nil then
        return
    end

    local value = ui_get(quick_peek_mode)

    if value == "Off" then
        local target = ui_get(leg_movement_ref)

        if target == "Never slide" then
            never_slide(cmd)
        end

        return
    end

    if value == "Always slide" then
        always_slide(cmd)
        return
    end

    if value == "Never slide" then
        never_slide(cmd)
        return
    end
end

client_set_event_callback("finish_command", on_finish_command)