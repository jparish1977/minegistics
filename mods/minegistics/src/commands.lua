minetest.register_chatcommand("toggle_fuel", {
    params = "",
    privs = { give = true },
    description = "Toggle Require Fuel",
    func = function(name, param)
        minetest.settings:set_bool("minegistics_require_fuel", not minetest.settings:get_bool("minegistics_require_fuel", true))
        REQUIRE_FUEL = minetest.settings:get_bool("minegistics_require_fuel", true) or not DEBUG_MODE
        minetest.log("default", "REQUIRE_FUEL: " .. tostring(REQUIRE_FUEL))
        return true
    end,
})
