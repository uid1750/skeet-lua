local vector = require 'vector'
local bit    = require 'bit'

local reference = {
    quick_peek      = { ui.reference('Rage', 'Other', 'Quick peek assist') },
    quick_peek_dist = ui.reference('Rage', 'Other', 'Quick peek assist distance'),
}

local prim_peek       = ui.new_checkbox('rage', 'Other', 'Peek circle')
local prim_peek_color = ui.new_color_picker('rage', 'Other', 'Peek circle color', 192, 138, 138, 255)

local efx = {
    peek_assist_pos = database.read('peek_circle_pos'),

    render_effect = function(self, effect, pos, color, parameters)
        if not effect.refreshed then
            client.delay_call(0.3, function()
                self:init(true)
            end)
        else
            for _, mat in pairs(effect.materials) do
                mat:color_modulate(color[1], color[2], color[3])
                mat:alpha_modulate(color[4] or 255)
            end
            effect.func(pos, table.unpack(parameters))
        end
    end,

    init = function(self, refreshed)
        self.energy_effect = {
            refreshed  = refreshed,
            func       = vtable_bind("client.dll", "IEffects001", 7, "void(__thiscall*)(void*, const Vector&, const Vector&, bool)"),
            materials  = {
                materialsystem.find_material("effects/spark",                   true),
                materialsystem.find_material("effects/combinemuzzle1_nocull",   true),
                materialsystem.find_material("effects/combinemuzzle2_nocull",   true),
            },
            parameters = { vector(0, 0, 0), true },
        }
    end,
}
efx:init(false)

local function peek_cir()
    local local_player = entity.get_local_player()
    if not local_player then return end

    if not ui.get(prim_peek) then return end
    if not ui.get(reference.quick_peek[1]) then return end

    local local_origin = vector(entity.get_origin(local_player))
    local efx_color    = { ui.get(prim_peek_color) }
    local speed        = 5

    local grounded  = bit.band(entity.get_prop(local_player, 'm_fFlags'), 1) == 1
    local velocity  = vector(entity.get_prop(local_player, 'm_vecVelocity')) / 5
    velocity.z      = 0

    if not ui.get(reference.quick_peek[2]) then
        if grounded then
            efx.peek_assist_pos = local_origin - velocity
        else
            efx.peek_assist_pos = local_origin
        end
    else
        local raw_dist = ui.get(reference.quick_peek_dist)
        local quick_peek_dist = raw_dist > 200 and math.huge or raw_dist
        local origin = local_origin + vector(0, 0, 1)

        efx.peek_assist_pos.z = math.min(local_origin.z, efx.peek_assist_pos.z)

        if (origin - efx.peek_assist_pos):length() > quick_peek_dist and grounded then
            efx.peek_assist_pos = (efx.peek_assist_pos - origin):normalized() * quick_peek_dist + origin
        end

        local t = globals.curtime() * (speed + 1)
        local curr_origin = efx.peek_assist_pos + vector(math.sin(t) * 20, math.cos(t) * 20, 1)
        efx:render_effect(efx.energy_effect, curr_origin, efx_color, { vector(0, 0, 0), true })

        database.write('peek_circle_pos', { efx.peek_assist_pos:unpack() })
    end
end

client.set_event_callback('paint', peek_cir)
