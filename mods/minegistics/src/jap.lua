--[[
    Minegistics-JAP
      Oldrot
]]--

minetest.register_chatcommand("toggle_fuel", {
    params = "",
    privs = { give = true },
    description = "Toggle Require Fuel",
    func = function(name, param)
        minetest.settings:set_bool("minegistics_require_fuel", not minetest.settings:get_bool("minegistics_require_fuel", true))
        return true
    end,
})
