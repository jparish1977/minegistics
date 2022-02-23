--[[
    Minegistics
      logalog
      Droog71
    License: AGPLv3
]]--

money = 100
local item_buttons = {}
local item_btn_keys = {}

local items_for_sale = {
    ["Collector"] = "minegistics:Collector",
    ["Power Plant"] = "minegistics:PowerPlant",
    ["Factory"] = "minegistics:Factory",
    ["Town"] = "minegistics:Town",
    ["Warehouse"] = "minegistics:Warehouse",
    ["Market"] = "minegistics:Market",
    ["Rail"] = "minegistics_trains:rail",
    ["Powered Rail"] = "minegistics_trains:power_rail",
    ["Brake Rail"] = "minegistics_trains:brake_rail",
    ["Train"] = "minegistics_trains:train"
}
item_prices = {
    ["Collector"] = 300,
    ["Factory"] = 400,
    ["Town"] = 200,
    ["Warehouse"] = 100,
    ["Market"] = 500,
    ["Rail"] = 20,
    ["Powered Rail"] = 200,
    ["Brake Rail"] = 40,
    ["Train"] = 100,
    ["Power Plant"] = 350
}

--defines the inventory formspec
function inventory_formspec(player)
    local power_check = power_display == true and "#" or ""
    local formspec = {
        "size[8,7.5]",
        "bgcolor[#2d2d2d;false]",
        "list[current_player;main;0,3.5;8,4;]",
        "button[3,0.9;2,0.5;Power;Power " .. power_check .. "]",
        "tooltip[Power;" ..
        "View power grid status." ..
        ";#353535;#FFFFFF]",
        "button[3,1.9;2,0.5;Shop;Shop]",
        "tooltip[Shop;" ..
        "Purchase buildings, trains and rails." ..
        ";#353535;#FFFFFF]",
    }
    return formspec
end

--defines the inventory formspec
function power_formspec(player)
    local power_info = ""
        for index,pos in pairs(power_producers) do
            local local_consumers = 0
            local local_producers = 0
            for index,consumer in pairs(power_consumers) do
                if vector.distance(consumer, pos) < 200 then
                    local_consumers = local_consumers + 1
                end
            end
            for index,producer in pairs(power_producers) do
                if vector.distance(producer, pos) < 200 then
                    local_producers = local_producers + 1
                end
            end
            local stable = local_consumers <= local_producers * 5
            local stable_display = stable and "stable" or "unstable"
            power_info = power_info .. local_consumers .. " consumers and " ..
            local_producers .. " producers for power plant at (" ..
            pos.x .. ", " .. pos.y .. ", " .. pos.z .. ")" ..
            " (" .. stable_display .. ")\n"
        end
    local power_check = power_display == true and "#" or ""
    local formspec = {
        "size[11,11]",
        "bgcolor[#353535;false]",
        "label[5,0.5;Power]",
        "scroll_container[1,1;12,8;power_scroll;vertical;0.1]",
        "label[1,1;" .. power_info .. "]",
        "scroll_container_end[]",
        "button[3.5,10;4,2;Back;Back]"
    }
    return formspec
end

minetest.register_on_joinplayer(function(player)
    local formspec = inventory_formspec(player)
    player:set_inventory_formspec(table.concat(formspec, ""))
end)

--defines the shop formspec
function shop_formspec(player)
    item_buttons = {}
    local index = 1
    for item_name,item in pairs(items_for_sale) do
        local stack = ItemStack(item)
        item_buttons[index] = "button[3," ..
            index .. ";4,2;" .. item_name ..
            ";" .. item_name .. "]" ..
            "item_image[7," .. index + 0.6 ..
            ";0.6,0.6;" .. item .. "]" ..
            "tooltip[" .. item_name .. ";" ..
            stack:get_description() .. ";#353535;#FFFFFF]" ..
            "label[8," .. index + 0.6 .. ";" .. " $" ..
            item_prices[item_name] .."]"
        item_btn_keys[item_name] = item
        index = index + 1
    end
    local formspec = {
        "size[10,16]",
        "bgcolor[#353535;false]",
        "label[4.5,0.5;Shop]",
        table.concat(item_buttons),
        "label[3.5,12;".."Your balance: $" .. money.."]",
        "button[3,13;4,2;Back;Back]"
    }
    return formspec
end

--handles clicked buttons
minetest.register_on_player_receive_fields(function(player, formname, fields)
    local player_name = player:get_player_name()
    if formname == "" then
        for key, val in pairs(fields) do
            if key == "Shop" then
                local formspec = shop_formspec(player)
                player:set_inventory_formspec(table.concat(formspec, ""))
            elseif key == "Back" then
                local formspec = inventory_formspec(player)
                player:set_inventory_formspec(table.concat(formspec, ""))
            elseif key == "Power" then
                local formspec = power_formspec(player)
                player:set_inventory_formspec(table.concat(formspec, ""))
            else
                for item_name,item in pairs(item_btn_keys) do
                    if key == item_name then
                        local stack = ItemStack(item)
                        if item_name == "Rail" then
                            stack:set_count(10)
                        end
                        if money >= item_prices[item_name] then
                            if player:get_inventory():add_item("main", stack) then
                                money = money - item_prices[item_name]
                                minetest.chat_send_player(
                                    player_name,"You bought a " .. item_name .. "!   " ..
                                    "$" .. money .. " remaining."
                                )
                                local formspec = shop_formspec(player)
                                player:set_inventory_formspec(table.concat(formspec, ""))
                            end
                        else
                            minetest.chat_send_player(player_name, "You can't afford that!")
                        end
                    end
                end
            end
        end
    end
end)
