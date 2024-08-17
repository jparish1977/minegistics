-- Enable debug mode
DEBUG_MODE = minetest.settings:get_bool("minegistics_debug", false)
-- To ease debugging, allow disabling the fuel requirement
REQUIRE_FUEL = minetest.settings:get_bool("minegistics_require_fuel", true) or not DEBUG_MODE

